{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- Most of this is taken from the Yesod.Core.Handler source

module Yesod.Banner
  ( BannerStatus (..),
    bannKey,
    addBanner,
    getBanners,
    mkBannersWidget,
  )
where

import ClassyPrelude
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as L
import qualified Data.Text as T
import Data.Text.Encoding (decodeUtf8With)
import Data.Text.Encoding.Error (lenientDecode)
import qualified Data.Word8 as W8
import Text.Blaze.Html (preEscapedToHtml)
import Text.Blaze.Html.Renderer.Utf8 (renderHtml)
import Text.Read (read)
import Yesod

data BannerStatus = Primary | Secondary | Success | Danger | Warning | Info | Light | Dark
  deriving (Show, Read)

bannKey :: Text
bannKey = "_BAN"

-- | Adds a banner with status.
addBanner :: MonadHandler m => BannerStatus -> Html -> m ()
addBanner status msg = do
  val <- lookupSessionBS bannKey
  setSessionBS bannKey $ addMsg val
  where
    addMsg = maybe msg' (BS.append msg' . BS.cons W8._nul)
    msg' =
      BS.append
        (encodeUtf8 $ T.pack $ show status)
        (W8._nul `BS.cons` L.toStrict (renderHtml msg))

-- | Gets all banners, then clears the session variable.
getBanners :: MonadHandler m => m [(BannerStatus, Html)]
getBanners = do
  bs <- lookupSessionBS bannKey
  let ms = maybe [] enlist bs
  deleteSession bannKey
  return ms
  where
    enlist = pairup . BS.split W8._nul
    pairup [] = []
    pairup [_] = []
    pairup (s : v : xs) = (read . T.unpack $ decode s, preEscapedToHtml (decode v)) : pairup xs
    decode = decodeUtf8With lenientDecode

-- | Makes a banner widget, with bootstrap classes and all
mkBannersWidget :: [(BannerStatus, Html)] -> WidgetFor site ()
mkBannersWidget banners =
  toWidgetBody
    [hamlet|
             $forall (status, content) <- banners
               <div .alert .alert-#{toLower $ show status}>#{content}
        |]
