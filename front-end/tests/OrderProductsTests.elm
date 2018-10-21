module OrderProductsTests exposing (orderProductsTests)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, intRange)
import Main exposing (Offer, OrderBy(..), Ordering, Product)
import Random
import Test exposing (..)


orderProductsTests : Test
orderProductsTests =
    describe "orderProducts"
        [ test "default doesn't change ordering when products are already in the right order" <|
            \_ ->
                let
                    expected =
                        [ Product 1 0 "A" 10 0 Nothing
                        , Product 2 1 "B" 20 0 Nothing
                        ]

                    order =
                        Ordering Default False

                    result =
                        Main.orderProducts expected order
                in
                Expect.equal expected result
        , test "default orders based on ordinal" <|
            \_ ->
                let
                    products =
                        [ Product 1 1 "A" 10 0 Nothing
                        , Product 2 0 "B" 20 0 Nothing
                        , Product 3 2 "C" 30 0 Nothing
                        ]

                    order =
                        Ordering Default False

                    result =
                        Main.orderProducts products order

                    expected =
                        [ Product 2 0 "B" 20 0 Nothing
                        , Product 1 1 "A" 10 0 Nothing
                        , Product 3 2 "C" 30 0 Nothing
                        ]
                in
                Expect.equal expected result
        , test "default reverses order when reverse is true" <|
            \_ ->
                let
                    products =
                        [ Product 1 0 "A" 10 0 Nothing
                        , Product 2 1 "B" 20 0 Nothing
                        ]

                    order =
                        Ordering Default True

                    result =
                        Main.orderProducts products order

                    expected =
                        List.reverse products
                in
                Expect.equal expected result
        , test "name orders by name" <|
            \_ ->
                let
                    products =
                        [ Product 1 0 "B" 10 0 Nothing
                        , Product 2 1 "A" 20 0 Nothing
                        ]

                    order =
                        Ordering Name False

                    result =
                        Main.orderProducts products order

                    expected =
                        [ Product 2 1 "A" 20 0 Nothing
                        , Product 1 0 "B" 10 0 Nothing
                        ]
                in
                Expect.equal expected result
        , test "price orders by name" <|
            \_ ->
                let
                    products =
                        [ Product 1 0 "B" 20 0 Nothing
                        , Product 2 1 "A" 10 0 Nothing
                        ]

                    order =
                        Ordering Name False

                    result =
                        Main.orderProducts products order

                    expected =
                        [ Product 2 1 "A" 10 0 Nothing
                        , Product 1 0 "B" 20 0 Nothing
                        ]
                in
                Expect.equal expected result
        ]
