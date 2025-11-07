{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DisambiguateRecordFields #-}

module SenseSpec (senseSpec) where

import Test.Hspec
import Network.Wai (requestMethod, pathInfo, requestHeaders)
import Network.Wai.Test (runSession, srequest, SRequest(..), defaultRequest, simpleBody, simpleStatus)
import qualified Data.ByteString.Lazy as LBS
import Network.HTTP.Types (methodGet, methodPost, methodPatch, methodDelete, status404, status204)
import Api.Server
import Data.Aeson (encode, eitherDecode)
import Api.Types

senseSpec :: Spec
senseSpec = describe "Sense API" $ do
  it "GET senses for lexeme returns empty list initially" $ do
    store <- newStore
    let app = mkApp store
    let req = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","lexemes","lex_42","senses"] } LBS.empty
    resp <- runSession (srequest req) app
    let body = simpleBody resp
    case eitherDecode body of
      Right (ss :: [Sense]) -> ss `shouldBe` []
      Left err -> expectationFailure err

  it "POST then GET senses for a lexeme" $ do
    store <- newStore
    let app = mkApp store
    let sense = Sense "sense_1" "lex_42" "The sun" (Just "sun") Nothing Nothing Nothing Nothing
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes","lex_42","senses"], requestHeaders = [("Content-Type","application/json")] } (encode sense)
    _ <- runSession (srequest postReq) app
    let getReq = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","lexemes","lex_42","senses"] } LBS.empty
    getResp <- runSession (srequest getReq) app
    let body = simpleBody getResp
    case eitherDecode body of
      Right (ss :: [Sense]) -> ss `shouldContain` [sense]
      Left err -> expectationFailure err

  it "GET sense by ID returns the specific sense" $ do
    store <- newStore
    let app = mkApp store
    let sense = Sense "sense_123" "lex_xyz" "A bright star" (Just "star") Nothing Nothing Nothing Nothing
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes","lex_xyz","senses"], requestHeaders = [("Content-Type","application/json")] } (encode sense)
    _ <- runSession (srequest postReq) app
    let getByIdReq = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","senses","sense_123"] } LBS.empty
    getResp <- runSession (srequest getByIdReq) app
    let body = simpleBody getResp
    case eitherDecode body of
      Right (foundSense :: Sense) -> sense_id foundSense `shouldBe` "sense_123"
      Left err -> expectationFailure err

  it "GET sense by ID returns 404 for non-existent sense" $ do
    store <- newStore
    let app = mkApp store
    let getByIdReq = SRequest defaultRequest { requestMethod = methodGet, pathInfo = ["api","v1","senses","sense_nonexistent"] } LBS.empty
    getResp <- runSession (srequest getByIdReq) app
    simpleStatus getResp `shouldBe` status404

  it "PATCH updates a sense" $ do
    store <- newStore
    let app = mkApp store
    let sense = Sense "sense_456" "lex_abc" "Original definition" (Just "orig") Nothing Nothing Nothing Nothing
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes","lex_abc","senses"], requestHeaders = [("Content-Type","application/json")] } (encode sense)
    _ <- runSession (srequest postReq) app
    let updatedSense = sense { definition = "Updated definition", gloss = Just "updated" }
    let patchReq = SRequest defaultRequest { requestMethod = methodPatch, pathInfo = ["api","v1","senses","sense_456"], requestHeaders = [("Content-Type","application/json")] } (encode updatedSense)
    patchResp <- runSession (srequest patchReq) app
    let body = simpleBody patchResp
    case eitherDecode body of
      Right (resultSense :: Sense) -> definition resultSense `shouldBe` "Updated definition"
      Left err -> expectationFailure err

  it "DELETE removes a sense" $ do
    store <- newStore
    let app = mkApp store
    let sense = Sense "sense_789" "lex_def" "To be deleted" Nothing Nothing Nothing Nothing Nothing
    let postReq = SRequest defaultRequest { requestMethod = methodPost, pathInfo = ["api","v1","lexemes","lex_def","senses"], requestHeaders = [("Content-Type","application/json")] } (encode sense)
    _ <- runSession (srequest postReq) app
    let deleteReq = SRequest defaultRequest { requestMethod = methodDelete, pathInfo = ["api","v1","senses","sense_789"] } LBS.empty
    deleteResp <- runSession (srequest deleteReq) app
    simpleStatus deleteResp `shouldBe` status204
