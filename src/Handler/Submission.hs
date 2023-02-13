{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | Handler
module Handler.Submission
  ( getSubmissionR,
  )
where

import Data.Maybe (fromJust)
import qualified Data.Text as T
import Import
import System.Exit (ExitCode)
import System.Process.Extra (system)
import Network.Runspawner.Protocol
import Yesod.Banner

-- | Parameters supported by the compile command substitutor
data CcParams = CcParams
  { infile :: FilePath,
    outfile :: FilePath
  }

-- | Extension of output files
outExt :: String
outExt = "out"

getSubmissionR :: SubmissionId -> Handler Html
getSubmissionR subId = do
  probTitle <-
    fmap problemTitle
      <$> (runDB . get . submissionProblem =<< runDB (get404 subId))
  subScore <- submissionScore <$> runDB (get404 subId)

  whenM
    ( (==)
        <$> (submissionScore <$> runDB (get404 subId))
        <*> pure (-1)
    )
    $ return () -- TODO: grade submisisons here

  defaultLayout $(widgetFile "subproc")

-- | Turns the compile command into a runnable string
--    by e.g. doing all the parameter substitutions.
realiseCc :: CcParams -> Text -> Text
realiseCc (CcParams inf outf) = realiseCc' [] False
  where
    rinf = reverse inf
    routf = reverse outf
    realiseCc' res _ "" = reverse $ T.concat res
    realiseCc' res subp cc' =
      realiseCc' res' (c == '%' && not subp) (T.tail cc')
      where
        c = T.head cc'
        res'
          | subp =
            case c of
              '%' -> "%" : res
              'i' -> T.pack rinf : res
              'o' -> T.pack routf : res
              _ -> res
          | c == '%' = res
          | otherwise = T.singleton c : res

gradeSubmission :: Submission -> IO ()
gradeSubmission sub = do
  let req = [""]

compileFile :: Submission -> Handler ExitCode
compileFile sub = do
  let inputfn = T.unpack $ submissionCodeFile sub
  let outputfn = T.unpack (submissionCodeFile sub) <.> outExt
  cmd <-
    realiseCc (CcParams inputfn outputfn)
      . problemCmdCommand
      . fromJust
      <$> ( runDB . get $
              ProblemCmdKey
                (submissionProblem sub)
                (submissionLanguage sub)
          )

  liftIO $ system $ T.unpack cmd
