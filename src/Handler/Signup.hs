{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.Signup where

import qualified Data.Text as T
import Database.Persist.Sqlite (fromSqlKey)
import Import
import Yesod
import Yesod.Auth.HashDB
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), bfs, renderBootstrap3)

data User' = User'
  { user'Uname :: T.Text,
    user'Password :: T.Text
  }

signupForm :: Form User'
signupForm =
  renderBootstrap3 BootstrapBasicForm $
    User'
      <$> areq textField (bfs' "Username") Nothing
      <*> areq textField (bfs' "Password") Nothing
  where
    bfs' :: Text -> FieldSettings site
    bfs' = bfs

getSignupR :: Handler Html
getSignupR = do
  (formWidget, enctype) <- generateFormPost signupForm
  defaultLayout $ do
    $(widgetFile "signup")

postSignupR :: Handler Html
postSignupR = do
  ((result, _), _) <- runFormPost signupForm
  case result of
    FormSuccess user' -> do
      time <- liftIO getCurrentTime
      user <- liftIO $ setPassword (user'Password user') $ User (user'Uname user') time ""
      _ <- runDB $ insert user
      redirect HomeR
    _ -> undefined
