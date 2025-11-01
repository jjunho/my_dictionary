module Main (main) where

import Test.Hspec
import Data.Aeson (encode, eitherDecode)
import Api.Types
import Data.ByteString.Lazy (toStrict)

main :: IO ()
main = hspec $ describe "Api.Types JSON" $ it "roundtrips Lexeme" $ do
  let lex = Lexeme "lex_01" "sula" "xyz"
      bs = encode lex
  case eitherDecode bs of
    Right (l :: Lexeme) -> l `shouldBe` lex
    Left err -> expectationFailure err
