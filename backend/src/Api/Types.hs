{-# LANGUAGE DeriveGeneric #-}

module Api.Types (Lexeme(..)) where

import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)
import Data.Text (Text)

-- Minimal Lexeme type for examples and tests
data Lexeme = Lexeme
  { id :: Text
  , lemma :: Text
  , language :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON Lexeme
instance FromJSON Lexeme
