{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}

module ServerSpec (serverSpec) where

import Test.Hspec
import Network.Wai (requestMethod, pathInfo, requestHeaders)
import Network.Wai.Test (runSession, srequest, SRequest(..), defaultRequest, simpleBody)
import qualified Data.ByteString.Lazy as LBS
import Network.HTTP.Types (methodGet, methodPost)
import Api.Server
import Data.Aeson (encode, eitherDecode)
import Api.Types

serverSpec :: Spec
serverSpec = describe "API server" $ do
  it "GET returns empty list initially" $ do
    store <- newStore
    let app = mkApp store
    let req = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","lexemes"] } LBS.empty
    resp <- runSession (srequest req) app
    let body = simpleBody resp
    case eitherDecode body of
      Right (ls :: [Lexeme]) -> ls `shouldBe` []
      Left err -> expectationFailure err

  it "POST then GET returns posted lexeme" $ do
    store <- newStore
    let app = mkApp store
    let lx = Lexeme "lex_42" "teste" "pt"
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes"], requestHeaders = [("Content-Type","application/json")] } (encode lx)
    _ <- runSession (srequest postReq) app
    let getReq = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","lexemes"] } LBS.empty
    getResp <- runSession (srequest getReq) app
    let body = simpleBody getResp
    case eitherDecode (body) of
      Right (ls :: [Lexeme]) -> ls `shouldContain` [lx]
      Left err -> expectationFailure err
