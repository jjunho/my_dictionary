{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Api.Server
  ( API
  , server
  , mkApp
  , InMemoryStore
  , newStore
  , readAll
  , addLexeme
  , getLexemeById
  , updateLexeme
  , deleteLexeme
  , getSensesForLexeme
  , addSense
  , getSenseById
  , updateSense
  , deleteSense
  ) where

import Servant
import Control.Monad.IO.Class (liftIO)
import Control.Concurrent.MVar
import Data.Text (Text)
import Api.Types
import Data.List (find)
import Data.Time (getCurrentTime)

type API = "api" :> "v1" :> "lexemes" :> Get '[JSON] [Lexeme]
      :<|> "api" :> "v1" :> "lexemes" :> ReqBody '[JSON] Lexeme :> Post '[JSON] Lexeme
      :<|> "api" :> "v1" :> "lexemes" :> Capture "id" Text :> Get '[JSON] Lexeme
      :<|> "api" :> "v1" :> "lexemes" :> Capture "id" Text :> ReqBody '[JSON] Lexeme :> Patch '[JSON] Lexeme
      :<|> "api" :> "v1" :> "lexemes" :> Capture "id" Text :> DeleteNoContent
      :<|> "api" :> "v1" :> "lexemes" :> Capture "id" Text :> "senses" :> Get '[JSON] [Sense]
      :<|> "api" :> "v1" :> "lexemes" :> Capture "id" Text :> "senses" :> ReqBody '[JSON] Sense :> Post '[JSON] Sense
      :<|> "api" :> "v1" :> "senses" :> Capture "id" Text :> Get '[JSON] Sense
      :<|> "api" :> "v1" :> "senses" :> Capture "id" Text :> ReqBody '[JSON] Sense :> Patch '[JSON] Sense
      :<|> "api" :> "v1" :> "senses" :> Capture "id" Text :> DeleteNoContent

data InMemoryStore = InMemoryStore 
  { storeLexemes :: MVar [Lexeme]
  , storeSenses :: MVar [Sense]
  }

newStore :: IO InMemoryStore
newStore = InMemoryStore <$> newMVar [] <*> newMVar []

readAll :: InMemoryStore -> IO [Lexeme]
readAll store = readMVar (storeLexemes store)

addLexeme :: InMemoryStore -> Lexeme -> IO Lexeme
addLexeme store lx = modifyMVar (storeLexemes store) $ \xs -> let xs' = xs ++ [lx] in pure (xs', lx)

getLexemeById :: InMemoryStore -> Text -> IO (Maybe Lexeme)
getLexemeById store lexId = do
  lxs <- readMVar (storeLexemes store)
  return $ find (\l -> Api.Types.id l == lexId) lxs

updateLexeme :: InMemoryStore -> Text -> Lexeme -> IO (Maybe Lexeme)
updateLexeme store lexId updatedLex = modifyMVar (storeLexemes store) $ \xs -> do
  let (before, after) = break (\l -> Api.Types.id l == lexId) xs
  case after of
    [] -> return (xs, Nothing)
    (_:rest) -> do
      now <- getCurrentTime
      let updated = updatedLex { metadata = (metadata updatedLex) { updated_at = now } }
      let xs' = before ++ [updated] ++ rest
      return (xs', Just updated)

deleteLexeme :: InMemoryStore -> Text -> IO Bool
deleteLexeme store lexId = modifyMVar (storeLexemes store) $ \xs -> do
  now <- getCurrentTime
  let (before, after) = break (\l -> Api.Types.id l == lexId) xs
  case after of
    [] -> return (xs, False)
    (lx:rest) -> do
      let deleted = lx { metadata = (metadata lx) { deleted_at = Just now } }
      let xs' = before ++ [deleted] ++ rest
      return (xs', True)

getSensesForLexeme :: InMemoryStore -> Text -> IO [Sense]
getSensesForLexeme store lexId = do
  allSenses <- readMVar (storeSenses store)
  return $ filter (\s -> lexeme_id s == lexId) allSenses

addSense :: InMemoryStore -> Sense -> IO Sense
addSense store sense = modifyMVar (storeSenses store) $ \xs -> let xs' = xs ++ [sense] in pure (xs', sense)

getSenseById :: InMemoryStore -> Text -> IO (Maybe Sense)
getSenseById store senseId = do
  allSenses <- readMVar (storeSenses store)
  return $ find (\s -> sense_id s == senseId) allSenses

updateSense :: InMemoryStore -> Text -> Sense -> IO (Maybe Sense)
updateSense store senseId updatedSense = modifyMVar (storeSenses store) $ \xs -> do
  let (before, after) = break (\s -> sense_id s == senseId) xs
  case after of
    [] -> return (xs, Nothing)
    (_:rest) -> do
      let xs' = before ++ [updatedSense] ++ rest
      return (xs', Just updatedSense)

deleteSense :: InMemoryStore -> Text -> IO Bool
deleteSense store senseId = modifyMVar (storeSenses store) $ \xs -> do
  let (before, after) = break (\s -> sense_id s == senseId) xs
  case after of
    [] -> return (xs, False)
    (_:rest) -> do
      let xs' = before ++ rest
      return (xs', True)

server :: InMemoryStore -> Server API
server store = 
  liftIO (readAll store) 
  :<|> (\lx -> liftIO (addLexeme store lx))
  :<|> (\lexId -> do
    maybeLex <- liftIO (getLexemeById store lexId)
    case maybeLex of
      Nothing -> throwError err404
      Just lexeme -> return lexeme)
  :<|> (\lexId updatedLex -> do
    result <- liftIO (updateLexeme store lexId updatedLex)
    case result of
      Nothing -> throwError err404
      Just lexeme -> return lexeme)
  :<|> (\lexId -> do
    success <- liftIO (deleteLexeme store lexId)
    if success then return NoContent else throwError err404)
  :<|> (\lexId -> liftIO (getSensesForLexeme store lexId))
  :<|> (\_lexId sense -> liftIO (addSense store sense))
  :<|> (\senseId -> do
    maybeSense <- liftIO (getSenseById store senseId)
    case maybeSense of
      Nothing -> throwError err404
      Just sense -> return sense)
  :<|> (\senseId updatedSense -> do
    result <- liftIO (updateSense store senseId updatedSense)
    case result of
      Nothing -> throwError err404
      Just sense -> return sense)
  :<|> (\senseId -> do
    success <- liftIO (deleteSense store senseId)
    if success then return NoContent else throwError err404)

mkApp :: InMemoryStore -> Application
mkApp store = serve (Proxy :: Proxy API) (server store)
