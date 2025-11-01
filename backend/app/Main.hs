{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Network.Wai.Handler.Warp (run)
import Servant
import Data.Text (Text)
import Api.Types

type API = "api" :> "v1" :> "lexemes" :> Get '[JSON] [Lexeme]

server :: Server API
server = getLexemes

	where
		getLexemes :: Handler [Lexeme]
		getLexemes = pure [ Lexeme "lex_01" "sula" "xyz" ]

api :: Proxy API
api = Proxy

app :: Application
app = serve api server

main :: IO ()
main = do
	putStrLn "Starting backend server on port 8080..."
	run 8080 app
