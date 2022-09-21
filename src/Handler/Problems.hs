{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.Problems
  ( getProblemsListR,
    getProblemsR,
    postProblemsR,
  )
where

import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Database.Persist.Sqlite (fromSqlKey)
import Import
import Yesod.Form.Bootstrap4 (BootstrapFormLayout (..), bfs, renderBootstrap4)

-- PROBLEMLIST

getProblemsListR :: Handler Html
getProblemsListR = do
  problems :: [Entity Problem] <- runDB (selectList [] [])
  defaultLayout $(widgetFile "problemslist")

-- INDIVIDUAL PROBLEM PAGE

langsM :: Handler [(Text, Key Language)]
langsM =
  map (\(Entity k v) -> (languageName v, k))
    <$> runDB (selectList [] [])

data SubmissionForm = SubmissionForm
  { language :: LanguageId,
    code :: FileInfo
  }

submissionForm :: [(Text, Key Language)] -> Form SubmissionForm
submissionForm langs =
  renderBootstrap4 BootstrapBasicForm $
    SubmissionForm
      <$> areq (selectFieldList langs) (bfs' "Language") Nothing
      <*> fileAFormReq (bfs' "Code file")
  where
    bfs' :: Text -> FieldSettings site
    bfs' = bfs

getProblemsR :: ProblemId -> Handler Html
getProblemsR probId = do
  prob <- runDB $ get404 probId
  let probTitle = problemTitle prob
      probContent = preEscapedToMarkup $ problemStatement prob
  (formWidget, enctype) <- generateFormPost . submissionForm =<< langsM
  defaultLayout $(widgetFile "problems")

postProblemsR :: ProblemId -> Handler Html
postProblemsR probId = do
  ((result, _), _) <- runFormPost . submissionForm =<< langsM
  case result of
    FormFailure e -> redirect (AddproblemR, [("failed", "1"), ("reason", T.pack $ show e)])
    FormMissing -> redirect (AddproblemR, [("failed", "1")])
    FormSuccess submission' -> do
      subBS <- fileSourceByteString $ code submission'
      let submission =
            Submission
              probId
              (language submission')
              0
              (T.decodeUtf8 subBS)
      redirect HomeR
