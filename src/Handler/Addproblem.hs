{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.Addproblem
  ( getAddproblemR,
    postAddproblemR,
  )
where

import Codec.Archive.Zip
import qualified Data.ByteString.Lazy as BS
import Data.Char
import Data.Maybe
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Database.Persist.Sqlite
import Import
import System.Directory
import Text.Read
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), bfs, renderBootstrap3)

data ProblemForm = ProblemForm
  { problemTitle' :: Text,
    problemStatement' :: FileInfo,
    problemPdfurl' :: Maybe Text,
    problemTags' :: Text,
    problemTlimit' :: Int,
    problemTests' :: FileInfo
  }

langsM :: Handler [(Text, Key Language)]
langsM =
  map (\(Entity k v) -> (languageName v, k))
    <$> runDB (selectList [] [])

addProblemFormM :: Html -> MForm Handler (FormResult ProblemForm, Widget)
addProblemFormM extra = do
  (titleRes, titleView) <- mreq textField (bfs' "Title") Nothing
  (stmtRes, stmtView) <- mreq fileField (bfs' "problem statement (HTML)") Nothing
  (pdfRes, pdfView) <- mopt urlField (bfs' "PDF URL") Nothing
  (tagsRes, tagsView) <- mreq textField (bfs' "Tags") Nothing
  (tlimRes, tlimView) <- mreq intField (bfs' "Tags") $ Just 1000
  (tcRes, tcView) <- mreq fileField (bfs' "Testcases (zipped)") Nothing

  let problemRes =
        ProblemForm
          <$> titleRes
          <*> stmtRes
          <*> pdfRes
          <*> tagsRes
          <*> tlimRes
          <*> tcRes
  let formWidget = do
        let views = [titleView, stmtView, pdfView, tagsView, tlimView, tcView]
        toWidget
          [lucius|
          |]
        [whamlet|
                #{extra}
                $forall view <- views
                  <div .form-group>
                    <label for=#{fvId view}>#{fvLabel view}
                    ^{fvInput view}
        |]
  return (problemRes, formWidget)
  where
    bfs' :: Text -> FieldSettings site
    bfs' = bfs

addProblemForm :: Form ProblemForm
addProblemForm =
  renderBootstrap3 BootstrapBasicForm $
    ProblemForm
      <$> areq textField (bfs' "Title") Nothing
      <*> fileAFormReq (bfs' "Problem statement (HTML)")
      <*> aopt urlField (bfs' "PDF URL") Nothing
      <*> areq textField (bfs' "Tags") Nothing
      <*> areq intField (bfs' "Time limit (ms)") (Just 1000)
      <*> fileAFormReq (bfs' "Testcases (zipped)")
  where
    bfs' :: Text -> FieldSettings site
    bfs' = bfs

getAddproblemR :: Handler Html
getAddproblemR = do
  (formWidget, enctype) <- generateFormPost addProblemFormM
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
    FormSuccess problem' -> do
      res <-
        ( do
            let pdir = T.toLower . filter (isDigit ||| isAlpha) $ problemTitle' problem'
            -- we create the dir first so if it fails we don't have a bad DB entry
            tcbs <- fileSourceByteString $ problemTests' problem'
            liftIO $ createProblemFiles tcbs pdir
            stmtbs <- fileSourceByteString $ problemStatement' problem'
            key <-
              runDB . insert $
                Problem
                  (problemTitle' problem')
                  (T.decodeUtf8 stmtbs)
                  pdir
                  (problemPdfurl' problem')
                  (problemTags' problem')
                  (problemTlimit' problem' * 1000)
            return $ Right key
          )
          `catch` \e ->
            return $ Left e

      either
        ( \(SomeException e) ->
            redirect
              ( AddproblemR,
                [("failed", "1"), ("reason", T.pack $ show e)]
              )
        )
        ( \k ->
            redirect
              ( AddproblemR,
                [("inserted", T.pack . show . fromSqlKey $ k)]
              )
        )
        res
  where
    (|||) = liftM2 (||)
