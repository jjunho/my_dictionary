{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Network.Wai.Handler.Warp (run)
import Api.Server (mkApp, newStore)

main :: IO ()
main = do
  putStrLn "Starting backend server on port 8080..."
  store <- newStore
  run 8080 (mkApp store)
