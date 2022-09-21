{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.Addproblem
  ( getAddproblemR,
    postAddproblemR,
  )
where

import Codec.Archive.Zip (ZipOption (..), extractFilesFromArchive, toArchive)
import qualified Data.ByteString.Lazy as BS
import Data.Char (isAlpha, isDigit)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Database.Persist.Sqlite (fromSqlKey)
import Import
import System.Directory (createDirectory)
import Text.Read (readMaybe)
import Yesod.Form.Bootstrap4 (bfs)

data ProblemForm = ProblemForm
  { problemTitle' :: Text,
    problemStatement' :: FileInfo,
    problemPdfurl' :: Maybe Text,
    problemTags' :: Text,
    problemTlimit' :: Int,
    problemTests' :: FileInfo,
    problemCcs' :: [(Key Language, Text)]
  }

langsM :: Handler [(Key Language, Text)]
langsM =
  map (\(Entity k v) -> (k, languageName v))
    <$> runDB (selectList [] [])

addProblemForm :: [(Key Language, Text)] -> Html -> MForm Handler (FormResult ProblemForm, Widget)
addProblemForm langs extra = do
  (titleRes, titleView) <- mreq textField (bfs' "Title") Nothing
  (stmtRes, stmtView) <- mreq fileField (bfs' "problem statement (HTML)") Nothing
  (pdfRes, pdfView) <- mopt urlField (bfs' "PDF URL") Nothing
  (tagsRes, tagsView) <- mreq textField (bfs' "Tags") Nothing
  (tlimRes, tlimView) <- mreq intField (bfs' "Time limit") $ Just 1000
  (tcRes, tcView) <- mreq fileField (bfs' "Testcases (zipped)") Nothing
  ccRVs <- forM (replicate (length langs) "") $ flip (mreq textField) Nothing

  let problemRes =
        ProblemForm
          <$> titleRes
          <*> stmtRes
          <*> pdfRes
          <*> tagsRes
          <*> tlimRes
          <*> tcRes
          <*> (zip (fst <$> langs) <$> sequenceA (fst <$> ccRVs))
  let formWidget = do
        let views = [titleView, stmtView, pdfView, tagsView, tlimView, tcView]
        let ccvns = zip (snd <$> langs) $ snd <$> ccRVs
        toWidget
          [lucius|
          |]
        [whamlet|
                #{extra}
                $forall view <- views
                  <div .form-group>
                    <label for=#{fvId view}>#{fvLabel view}
                    ^{fvInput view}

                <table .table>
                  <thead .thead-dark>
                    <tr>
                      <th>Language
                      <th>Compile command
                  <tbody>
                    $forall (name, view) <- ccvns
                      <tr>
                        <th>#{name}
                        <th>^{fvInput view}
        |]
  return (problemRes, formWidget)
  where
    bfs' :: Text -> FieldSettings site
    bfs' = bfs

getAddproblemR :: Handler Html
getAddproblemR = do
  langs <- langsM
  (formWidget, enctype) <- generateFormPost $ addProblemForm langs
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
  -- create problem dir if it doesn't exist
  void $ try @_ @SomeException . createDirectory . T.unpack . appProblemDir $ compileTimeAppSettings
  createDirectory pdir
  extractFilesFromArchive [OptDestination pdir] $ toArchive . BS.fromStrict $ zipfilecont
  return ()

postAddproblemR :: Handler Html
postAddproblemR = do
  ((result, _), _) <- runFormPost . addProblemForm =<< langsM
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

            mapM_ (\(l, c) -> void . runDB . insert $ ProblemCmd key l c) $ problemCcs' problem'

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
