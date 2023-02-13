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
import System.Directory (createDirectoryIfMissing)
import Text.Read (readMaybe)
import Yesod.Banner
import Yesod.Form.Bootstrap4 (bfs)

getAddproblemR :: Handler Html
getAddproblemR = do
  langs <- langsM
  (formWidget, enctype) <- generateFormPost $ addProblemForm langs
  defaultLayout $ do
    setTitle "Add problem"
    inserted' <- lookupGetParam "inserted"
    let inserted :: Maybe Int = (readMaybe . T.unpack) =<< inserted'
    $(widgetFile "addproblem")

postAddproblemR :: Handler Html
postAddproblemR = do
  ((result, _), _) <- runFormPost . addProblemForm =<< langsM
  case result of
    FormFailure e -> addBanner Danger [shamlet|<div>#{show e}|] >> redirect AddproblemR
    FormMissing -> addBanner Danger "Wtf?" >> redirect AddproblemR
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
        ( \(SomeException e) -> do
            addBanner Danger [shamlet|<div>#{show e}|]
            redirect AddproblemR
        )
        ( \k -> do
            addBanner Success [shamlet|<div>Added problem ##{show (fromSqlKey k)}|]
            redirect HomeR
        )
        res
  where
    (|||) = liftM2 (||)

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
          <*> (zip (fst <$> langs) <$> traverse fst ccRVs)
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

createProblemFiles :: ByteString -> T.Text -> IO ()
createProblemFiles zipfilecont dirname = do
  let pdir = T.unpack (appProblemDir compileTimeAppSettings) ++ "/" ++ T.unpack dirname
  createDirectoryIfMissing True pdir
  extractFilesFromArchive [OptDestination pdir] $ toArchive . BS.fromStrict $ zipfilecont
  return ()
