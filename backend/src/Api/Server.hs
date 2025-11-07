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

newtype InMemoryStore = InMemoryStore (MVar [Lexeme])

newStore :: IO InMemoryStore
newStore = InMemoryStore <$> newMVar []

readAll :: InMemoryStore -> IO [Lexeme]
readAll (InMemoryStore mv) = readMVar mv

addLexeme :: InMemoryStore -> Lexeme -> IO Lexeme
addLexeme (InMemoryStore mv) lx = modifyMVar mv $ \xs -> let xs' = xs ++ [lx] in pure (xs', lx)

getLexemeById :: InMemoryStore -> Text -> IO (Maybe Lexeme)
getLexemeById (InMemoryStore mv) lexId = do
  lexemes <- readMVar mv
  return $ find (\l -> Api.Types.id l == lexId) lexemes

updateLexeme :: InMemoryStore -> Text -> Lexeme -> IO (Maybe Lexeme)
updateLexeme (InMemoryStore mv) lexId updatedLex = modifyMVar mv $ \xs -> do
  let (before, after) = break (\l -> Api.Types.id l == lexId) xs
  case after of
    [] -> return (xs, Nothing)
    (_:rest) -> do
      now <- getCurrentTime
      let updated = updatedLex { metadata = (metadata updatedLex) { updated_at = now } }
      let xs' = before ++ [updated] ++ rest
      return (xs', Just updated)

deleteLexeme :: InMemoryStore -> Text -> IO Bool
deleteLexeme (InMemoryStore mv) lexId = modifyMVar mv $ \xs -> do
  now <- getCurrentTime
  let (before, after) = break (\l -> Api.Types.id l == lexId) xs
  case after of
    [] -> return (xs, False)
    (lx:rest) -> do
      let deleted = lx { metadata = (metadata lx) { deleted_at = Just now } }
      let xs' = before ++ [deleted] ++ rest
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

mkApp :: InMemoryStore -> Application
mkApp store = serve (Proxy :: Proxy API) (server store)
