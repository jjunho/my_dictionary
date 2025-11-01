module Main (main) where

import Test.Hspec
import ServerSpec (serverSpec)

main :: IO ()
main = hspec $ do
	describe "sanity" $ it "true is true" $ True `shouldBe` True
	serverSpec
