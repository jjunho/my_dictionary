module Main (main) where

import Test.Hspec

main :: IO ()
main = hspec $ describe "sanity" $ it "true is true" $ True `shouldBe` True
