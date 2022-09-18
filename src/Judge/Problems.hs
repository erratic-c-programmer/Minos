{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

module Judge.Problems
  ( Testcase,
    readTCDir,
  )
where

import Control.Exception (SomeException, catch)
import Control.Monad (zipWithM)
import Data.List.Extra (groupBy, sortOn, stripSuffix)
import Data.Maybe (mapMaybe)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import System.Directory (listDirectory)

-- | Alias for a tuple representing a testcase: (input, output).
type Testcase = (T.Text, T.Text)

-- | Parses a directory of testcases into a @[[`Testcase`]]@. Takes a path to a directory and
--   returns a list of subtasks, each containing seperate testcases.
--
--   #tcdirfmt#
--   Testcase directories should have @\<subtask\>.\<testcase\>.{in,out}@, where @subtask@ and
--   @testcase@ are natural numbers. All input\/output files without corresponding output\/input
--   files will be ignored, as well as all other files in different formats in the filename.
readTCDir :: String -> IO [[Testcase]]
readTCDir dirName = do
  tcfs <- catch (listDirectory dirName) (\(_ :: SomeException) -> return [])
  -- not the most efficient (amortised quadratic), but it doesn't really matter
  let nosufs =
        let xs = mapMaybe (stripSuffix ".in") tcfs
         in filter (\x -> x ++ ".out" `elem` tcfs) xs
  let ins = map (\x -> dirName ++ "/" ++ x ++ ".in") nosufs
  let outs = map (\x -> dirName ++ "/" ++ x ++ ".out") nosufs

  map (map snd) . groupBy getSubTask . sortOn fst . zip ins <$> zipWithM ftoTC ins outs
  where
    ftoTC i o = (,) <$> TIO.readFile i <*> TIO.readFile o
    getSubTask (s1, _) (s2, _) = takeWhile (/= '.') s1 == takeWhile (/= '.') s2
