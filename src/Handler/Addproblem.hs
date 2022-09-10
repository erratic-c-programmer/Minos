{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.Addproblem where

import qualified Data.Text as T
import Database.Persist.Sqlite (fromSqlKey)
import Import
import Text.Julius (RawJS (..))
import Text.Read
import Yesod
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), bfs, renderBootstrap3)

addProblemForm :: Form Problem
addProblemForm =
  renderBootstrap3 BootstrapBasicForm $
    Problem
      <$> areq textField (bfs' "Title") Nothing
      <*> areq textField (bfs' "Filepath") Nothing
      <*> aopt urlField (bfs' "PDF URL") Nothing
      <*> areq textField (bfs' "Tags") Nothing
      <*> areq intField (bfs' "Time limit") (Just 1000000)
  where
    bfs' :: Text -> FieldSettings site
    bfs' = bfs

getAddproblemR :: Handler Html
getAddproblemR = do
  (formWidget, enctype) <- generateFormPost addProblemForm
  defaultLayout $ do
    setTitle "Add problem"
    failedp' <- lookupGetParam "failed"
    inserted' <- lookupGetParam "inserted"
    let failedp = failedp' == pure "1"
    let inserted :: Maybe Int = (readMaybe . T.unpack) =<< inserted'
    $(widgetFile "addproblem")

postAddproblemR :: Handler Html
postAddproblemR = do
  ((result, _), _) <- runFormPost addProblemForm
  case result of
    FormSuccess problem -> do
      key <- runDB $ insert problem
      redirect (AddproblemR, [("inserted", T.pack $ show $ fromSqlKey key)])
    _ -> redirect (AddproblemR, [("failed", "1")])
