module GetProductTests exposing (getProductTests)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, intRange)
import Main exposing (Offer, Product)
import Random
import Test exposing (..)


getProductTests : Test
getProductTests =
    describe "getProduct"
        [ fuzz int "returns product with the given id" <|
            \id ->
                let
                    expectedProduct =
                        Product id 2 "C" 20 0 Nothing

                    products =
                        [ expectedProduct
                        ]

                    result =
                        Main.getProduct id products
                in
                case result of
                    Just product ->
                        Expect.equal expectedProduct product

                    Nothing ->
                        Expect.fail "Could not find product with specified id"
        , fuzz int "returns only the first product with a given id" <|
            \id ->
                let
                    expectedProduct =
                        Product id 2 "C" 20 0 Nothing

                    unexpectedProduct =
                        Product id 3 "B" 40 0 Nothing

                    products =
                        [ expectedProduct
                        , unexpectedProduct
                        ]

                    result =
                        Main.getProduct id products
                in
                case result of
                    Just product ->
                        Expect.equal expectedProduct product

                    Nothing ->
                        Expect.fail "Could not find product with specified id"
        , fuzz (intRange 5 Random.maxInt) "returns Nothing when the specified id could not be found" <|
            \id ->
                let
                    products =
                        [ Product 1 0 "A" 50 0 (Just (Offer 1 "3 for 130" 3 20 False 0 0))
                        , Product 2 1 "B" 30 0 (Just (Offer 2 "2 for 45" 2 15 False 0 0))
                        , Product 3 2 "C" 20 0 Nothing
                        , Product 4 3 "D" 15 0 Nothing
                        ]

                    result =
                        Main.getProduct id products
                in
                case result of
                    Just product ->
                        Expect.fail "Found Just product when expected was Nothing"

                    Nothing ->
                        Expect.pass
        ]
