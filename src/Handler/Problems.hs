{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.Problems
  ( getProblemsListR,
    getProblemsR,
    postProblemsR,
  )
where

import Data.Maybe (fromJust)
import qualified Data.Text as T
import Database.Persist.Sqlite (fromSqlKey)
import Import
import System.Directory (createDirectoryIfMissing, listDirectory)
import Yesod.Banner
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

saveSubmission :: ProblemId -> Language -> UserId -> ByteString -> IO Text
saveSubmission probId lang userId subCont = do
  let sdir =
        T.unpack (appSubmissionDir compileTimeAppSettings)
          ++ "/"
          ++ show probId
          ++ "/"
          ++ show userId
  createDirectoryIfMissing True sdir
  nUSubs <- length <$> listDirectory sdir
  let filename =
        sdir
          ++ "/"
          ++ show (nUSubs + 1)
          ++ "."
          ++ T.unpack (languageFileext lang)
  writeFile filename subCont
  return $ T.pack filename

postProblemsR :: ProblemId -> Handler Html
postProblemsR probId = do
  ((result, _), _) <- runFormPost . submissionForm =<< langsM
  case result of
    FormFailure e -> addBanner Danger [shamlet|<div>#{show e}|]
    FormMissing -> addBanner Danger "Wtf?"
    FormSuccess submission' -> do
      ( do
          mlang <- runDB $ get $ language submission'
          maid <- maybeAuthId
          let lang = fromJust mlang
          let userId = fromJust maid
          subBS <- fileSourceByteString $ code submission'
          subfile <-
            liftIO $ saveSubmission probId lang userId subBS
          let submission = Submission probId (language submission') 0 subfile
          subId <- runDB $ insert submission
          void $ runDB $ insert $ UserSolves userId subId
          addBanner Success [shamlet|<div>Submission received|]
        )
        `catch` \(SomeException e) -> addBanner Danger [shamlet|<div>#{show e}|]

  redirect HomeR
