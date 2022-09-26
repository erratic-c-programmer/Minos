{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.SubProc
  ( getSubProcR
  )
where

import Data.Maybe (fromJust)
import qualified Data.Text as T
import Import
import System.Exit (ExitCode)
import System.Process.Extra (system)

-- | Parameters supported by the compile command substitutor
data CcParams = CcParams
  { infile :: FilePath,
    outfile :: FilePath
  }

-- | Extension of output files
outExt :: String
outExt = "out"

-- |
--  Turns the compile command into a runnable string
--  by e.g. doing all the parameter substitutions.
realiseCc :: CcParams -> Text -> Text
realiseCc (CcParams inf outf) = realiseCc' [] False
  where
    rinf = reverse inf
    routf = reverse outf
    realiseCc' res _ "" = reverse $ foldl' (++) "" res
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

compileFile :: Submission -> Handler ExitCode
compileFile sub = do
  let inputfn = T.unpack $ submissionCodeFile sub
  let outputfn = T.unpack (submissionCodeFile sub) <.> outExt
  cmd <-
    realiseCc (CcParams inputfn outputfn) .
    problemCmdCommand .
    fromJust
      <$> ( runDB . get $
              ProblemCmdKey
                (submissionProblem sub)
                (submissionLanguage sub)
          )

  liftIO $ system $ T.unpack cmd

getSubProcR :: ProblemId -> Handler Html
getSubProcR probId = undefined
