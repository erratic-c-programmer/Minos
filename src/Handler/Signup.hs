{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Handler.Signup
  ( getSignupR,
    postSignupR,
  )
where

import qualified Data.Text as T
import Import
import Yesod.Auth.HashDB
import Yesod.Form.Bootstrap4 (BootstrapFormLayout (..), bfs, renderBootstrap4)

data User' = User'
  { userUname' :: T.Text,
    userPassword' :: T.Text
  }

signupForm :: Form User'
signupForm =
  renderBootstrap4 BootstrapBasicForm $
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
      user <- liftIO $ setPassword (userPassword' user') $ User (userUname' user') time ""
      _ <- runDB $ insert user
      redirect HomeR
    _ -> undefined
