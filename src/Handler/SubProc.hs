{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.SubProc
  ( getSubProcR,
  )
where

import qualified Data.Text as T
import Import

data CcParams = CcParams
  { infile :: FilePath,
    outfile :: FilePath
  }

-- |
--  Turns the compile command into a runnable string
--  by e.g. doing all the parameter substitutions.
realiseCc :: CcParams -> Text -> Text
realiseCc (CcParams inf outf) cc = realiseCc' [] False $ reverse cc
  where
    rinf = reverse inf
    routf = reverse outf
    realiseCc' res _ "" = foldl' (++) "" res
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

compileFile :: Submission -> Language -> IO ()
compileFile sub lang = do
  let inputf = submissionCodeFile sub
  let outputf = T.unpack (submissionCodeFile sub) <.> "out"
  return ()

getSubProcR :: Handler Html
getSubProcR = undefined
