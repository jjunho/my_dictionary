{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}

module Api.Types 
  ( Lexeme(..)
  , LanguageRef(..)
  , Orthography(..)
  , Phonology(..)
  , Morphology(..)
  , Morpheme(..)
  , Etymology(..)
  , Source(..)
  , Metadata(..)
  ) where

import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON, toJSON, parseJSON, withObject, (.:), (.:?), object, (.=))
import Data.Text (Text)
import Data.Time (UTCTime)

-- Language reference (BCP-47)
data LanguageRef = LanguageRef
  { language_code :: Text
  , glottocode :: Maybe Text
  } deriving (Show, Eq, Generic)

instance ToJSON LanguageRef
instance FromJSON LanguageRef

-- Orthography information
data Orthography = Orthography
  { primary :: Text
  , alternates :: Maybe [Text]
  , unicode_normalization :: Maybe Text
  , orthography_tag :: Maybe Text
  } deriving (Show, Eq, Generic)

instance ToJSON Orthography
instance FromJSON Orthography

-- Phonology information
data Phonology = Phonology
  { phonemic_ipa :: Maybe Text
  , phonetic_ipa :: Maybe Text
  , syllabification :: Maybe Text
  } deriving (Show, Eq, Generic)

instance ToJSON Phonology
instance FromJSON Phonology

-- Morpheme in morphology breakdown
data Morpheme = Morpheme
  { text :: Text
  , gloss :: Text
  , morpheme_type :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON Morpheme where
  toJSON (Morpheme t g mt) = object
    [ "text" .= t
    , "gloss" .= g
    , "type" .= mt
    ]

instance FromJSON Morpheme where
  parseJSON = withObject "Morpheme" $ \v -> Morpheme
    <$> v .: "text"
    <*> v .: "gloss"
    <*> v .: "type"

-- Morphology information
data Morphology = Morphology
  { morphemes :: Maybe [Morpheme]
  } deriving (Show, Eq, Generic)

instance ToJSON Morphology
instance FromJSON Morphology

-- Etymology information
data Etymology = Etymology
  { text :: Text
  , source_language :: Maybe Text
  } deriving (Show, Eq, Generic)

instance ToJSON Etymology
instance FromJSON Etymology

-- Source information
data Source = Source
  { source_type :: Text
  , reference :: Text
  , license :: Maybe Text
  } deriving (Show, Eq, Generic)

instance ToJSON Source where
  toJSON (Source st ref lic) = object
    [ "type" .= st
    , "reference" .= ref
    , "license" .= lic
    ]

instance FromJSON Source where
  parseJSON = withObject "Source" $ \v -> Source
    <$> v .: "type"
    <*> v .: "reference"
    <*> v .:? "license"

-- Metadata for tracking
data Metadata = Metadata
  { project_id :: Maybe Text
  , created_at :: UTCTime
  , updated_at :: UTCTime
  , latest_revision_id :: Maybe Text
  , deleted_at :: Maybe UTCTime
  } deriving (Show, Eq, Generic)

instance ToJSON Metadata
instance FromJSON Metadata

-- Main Lexeme type
data Lexeme = Lexeme
  { id :: Text
  , lemma :: Text
  , part_of_speech :: Maybe Text
  , language :: LanguageRef
  , orthography :: Maybe Orthography
  , phonology :: Maybe Phonology
  , morphology :: Maybe Morphology
  , senses :: Maybe [Text]
  , etymology :: Maybe Etymology
  , tags :: Maybe [Text]
  , sources :: Maybe [Source]
  , metadata :: Metadata
  } deriving (Show, Eq, Generic)

instance ToJSON Lexeme
instance FromJSON Lexeme
