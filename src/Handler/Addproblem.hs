{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.Addproblem where

import Codec.Archive.Zip
import qualified Data.ByteString.Lazy as BS
import Data.Char
import Data.Maybe
import qualified Data.Text as T
import Database.Persist.Sqlite (fromSqlKey)
import Import
import Settings (compileTimeAppSettings)
import System.Directory
import Text.Read
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), bfs, renderBootstrap3)

data ProblemForm = ProblemForm
  { problemTitle' :: Text
  , problemPdfurl' :: Maybe Text
  , problemTags' :: Text
  , problemTlimit' :: Int
  , problemTests' :: FileInfo
  }

addProblemForm :: Form ProblemForm
addProblemForm =
  renderBootstrap3 BootstrapBasicForm $
    ProblemForm
      <$> areq textField (bfs' "Title") Nothing
      <*> aopt urlField (bfs' "PDF URL") Nothing
      <*> areq textField (bfs' "Tags") Nothing
      <*> areq intField (bfs' "Time limit (μs)") (Just 1000000)
      <*> fileAFormReq (bfs' "Testcases (zipped)")
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
    reason' <- lookupGetParam "reason"
    let failedp = failedp' == pure "1"
    let inserted :: Maybe Int = (readMaybe . T.unpack) =<< inserted'
    let reason = fromMaybe "unknown" reason'
    $(widgetFile "addproblem")

createProblemFiles :: ByteString -> T.Text -> IO ()
createProblemFiles zipfilecont dirname = do
  let pdir = T.unpack (appProblemDir compileTimeAppSettings) ++ "/" ++ T.unpack dirname
  createDirectory pdir
  extractFilesFromArchive [OptDestination pdir] $ toArchive . BS.fromStrict $ zipfilecont
  return ()

postAddproblemR :: Handler Html
postAddproblemR = do
  ((result, _), _) <- runFormPost addProblemForm
  case result of
    FormFailure e -> redirect (AddproblemR, [("failed", "1"), ("reason", T.pack $ show e)])
    FormMissing -> redirect (AddproblemR, [("failed", "1")])
    FormSuccess problem' ->
      ( do
          let pdir = T.toLower . filter (isDigit ||| isAlpha) $ problemTitle' problem'
          -- we create the dir first so if it fails we don't have a bad DB entry
          tcbs <- fileSourceByteString $ problemTests' problem'
          liftIO $ createProblemFiles tcbs pdir
          key <-
            runDB . insert $
              Problem
                (problemTitle' problem')
                pdir
                (problemPdfurl' problem')
                (problemTags' problem')
                (problemTlimit' problem')
          redirect (AddproblemR, [("inserted", T.pack . show . fromSqlKey $ key)])
      )
        `catch` \(SomeException e) ->
          redirect (AddproblemR, [("failed", "1"), ("reason", T.pack $ show e)])
  where
    (|||) = liftM2 (||)
