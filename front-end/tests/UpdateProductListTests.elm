module UpdateProductListTests exposing (updateProductListTests)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, intRange)
import Main exposing (Offer, Product)
import Random
import Test exposing (..)


updateProductListTests : Test
updateProductListTests =
    describe "updateProductList"
        [ fuzz (intRange 5 Random.maxInt) "updates the product with the given id" <|
            \id ->
                let
                    expectedProduct =
                        Product id 2 "F" 20 0 Nothing

                    products =
                        [ Product 1 0 "A" 50 0 (Just (Offer 1 "3 for 130" 3 20 False 0 0))
                        , Product 2 1 "B" 30 0 (Just (Offer 2 "2 for 45" 2 15 False 0 0))
                        , Product 3 2 "C" 20 0 Nothing
                        , Product 4 3 "D" 15 0 Nothing
                        , Product id 4 "E" 10 0 Nothing
                        ]

                    result =
                        Main.updateProductList expectedProduct products
                in
                Expect.true "Could not find updated element in returned list" (List.member expectedProduct result)
        , fuzz (intRange 5 Random.maxInt) "does not update the list when a product with the given id does not exist" <|
            \id ->
                let
                    unexpectedProduct =
                        Product id 2 "F" 20 0 Nothing

                    products =
                        [ Product 1 0 "A" 50 0 (Just (Offer 1 "3 for 130" 3 20 False 0 0))
                        , Product 2 1 "B" 30 0 (Just (Offer 2 "2 for 45" 2 15 False 0 0))
                        , Product 3 2 "C" 20 0 Nothing
                        , Product 4 3 "D" 15 0 Nothing
                        ]

                    result =
                        Main.updateProductList unexpectedProduct products
                in
                Expect.false "Found unexpected element in list" (List.member unexpectedProduct result)
        ]
