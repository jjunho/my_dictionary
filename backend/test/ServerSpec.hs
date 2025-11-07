{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}

module ServerSpec (serverSpec) where

import Test.Hspec
import Network.Wai (requestMethod, pathInfo, requestHeaders)
import Network.Wai.Test (runSession, srequest, SRequest(..), defaultRequest, simpleBody, simpleStatus)
import qualified Data.ByteString.Lazy as LBS
import Network.HTTP.Types (methodGet, methodPost, methodPatch, methodDelete, status404, status204)
import Api.Server
import Data.Aeson (encode, eitherDecode)
import Api.Types
import Data.Time (getCurrentTime)

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
    now <- getCurrentTime
    let lang = LanguageRef "pt" Nothing
    let meta = Metadata Nothing now now Nothing Nothing
    let lx = Lexeme "lex_42" "teste" (Just "noun") lang Nothing Nothing Nothing Nothing Nothing Nothing Nothing meta
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes"], requestHeaders = [("Content-Type","application/json")] } (encode lx)
    _ <- runSession (srequest postReq) app
    let getReq = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","lexemes"] } LBS.empty
    getResp <- runSession (srequest getReq) app
    let body = simpleBody getResp
    case eitherDecode (body) of
      Right (ls :: [Lexeme]) -> ls `shouldContain` [lx]
      Left err -> expectationFailure err

  it "GET by ID returns the specific lexeme" $ do
    store <- newStore
    let app = mkApp store
    now <- getCurrentTime
    let lang = LanguageRef "xyz" Nothing
    let meta = Metadata Nothing now now Nothing Nothing
    let lx = Lexeme "lex_123" "sula" (Just "noun") lang Nothing Nothing Nothing Nothing Nothing Nothing Nothing meta
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes"], requestHeaders = [("Content-Type","application/json")] } (encode lx)
    _ <- runSession (srequest postReq) app
    let getByIdReq = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","lexemes","lex_123"] } LBS.empty
    getResp <- runSession (srequest getByIdReq) app
    let body = simpleBody getResp
    case eitherDecode body of
      Right (foundLx :: Lexeme) -> Api.Types.id foundLx `shouldBe` "lex_123"
      Left err -> expectationFailure err

  it "GET by ID returns 404 for non-existent lexeme" $ do
    store <- newStore
    let app = mkApp store
    let getByIdReq = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","lexemes","lex_nonexistent"] } LBS.empty
    getResp <- runSession (srequest getByIdReq) app
    simpleStatus getResp `shouldBe` status404

  it "PATCH updates a lexeme" $ do
    store <- newStore
    let app = mkApp store
    now <- getCurrentTime
    let lang = LanguageRef "xyz" Nothing
    let meta = Metadata Nothing now now Nothing Nothing
    let lx = Lexeme "lex_456" "original" (Just "verb") lang Nothing Nothing Nothing Nothing Nothing Nothing Nothing meta
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes"], requestHeaders = [("Content-Type","application/json")] } (encode lx)
    _ <- runSession (srequest postReq) app
    let updatedLx = lx { lemma = "updated" }
    let patchReq = SRequest defaultRequest { requestMethod = methodPatch, pathInfo = ["api","v1","lexemes","lex_456"], requestHeaders = [("Content-Type","application/json")] } (encode updatedLx)
    patchResp <- runSession (srequest patchReq) app
    let body = simpleBody patchResp
    case eitherDecode body of
      Right (resultLx :: Lexeme) -> lemma resultLx `shouldBe` "updated"
      Left err -> expectationFailure err

  it "DELETE soft-deletes a lexeme" $ do
    store <- newStore
    let app = mkApp store
    now <- getCurrentTime
    let lang = LanguageRef "xyz" Nothing
    let meta = Metadata Nothing now now Nothing Nothing
    let lx = Lexeme "lex_789" "toDelete" (Just "adj") lang Nothing Nothing Nothing Nothing Nothing Nothing Nothing meta
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes"], requestHeaders = [("Content-Type","application/json")] } (encode lx)
    _ <- runSession (srequest postReq) app
    let deleteReq = SRequest defaultRequest { requestMethod = methodDelete, pathInfo = ["api","v1","lexemes","lex_789"] } LBS.empty
    deleteResp <- runSession (srequest deleteReq) app
    simpleStatus deleteResp `shouldBe` status204
