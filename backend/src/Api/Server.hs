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
  ) where

import Servant
import Control.Monad.IO.Class (liftIO)
import Network.Wai (Application)
import Network.Wai.Handler.Warp (run)
import Control.Concurrent.MVar
import Data.Text (Text)
import Api.Types

type API = "api" :> "v1" :> "lexemes" :> Get '[JSON] [Lexeme]
      :<|> "api" :> "v1" :> "lexemes" :> ReqBody '[JSON] Lexeme :> Post '[JSON] Lexeme

newtype InMemoryStore = InMemoryStore (MVar [Lexeme])

newStore :: IO InMemoryStore
newStore = InMemoryStore <$> newMVar []

readAll :: InMemoryStore -> IO [Lexeme]
readAll (InMemoryStore mv) = readMVar mv

addLexeme :: InMemoryStore -> Lexeme -> IO Lexeme
addLexeme (InMemoryStore mv) lx = modifyMVar mv $ \xs -> let xs' = xs ++ [lx] in pure (xs', lx)

server :: InMemoryStore -> Server API
server store = liftIO (readAll store) :<|> (\lx -> liftIO (addLexeme store lx))

mkApp :: InMemoryStore -> Application
mkApp store = serve (Proxy :: Proxy API) (server store)
