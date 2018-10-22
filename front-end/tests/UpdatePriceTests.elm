module UpdatePriceTests exposing (updatePriceTests)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, intRange)
import Main exposing (Offer, Product)
import Random
import Test exposing (..)


updatePriceTests : Test
updatePriceTests =
    describe "updatePrice"
        [ fuzz2 int int "returns cost of items added together when there are no offers" <|
            \productAmount productCost ->
                let
                    products =
                        [ Product 1 0 "A" productCost productAmount Nothing
                        , Product 2 1 "B" productCost productAmount Nothing
                        ]

                    expected =
                        (productAmount * productCost) * List.length products

                    result =
                        Main.updatePrice products
                in
                Expect.equal expected result
        , fuzz2 (intRange 1 Random.maxInt) (intRange 20 Random.maxInt) "returns cost of items added together minus offers when there are offers and the price is always higher than the maximum offer reduction" <|
            \productAmount productCost ->
                let
                    offerReduction =
                        20

                    products =
                        [ Product 1 0 "A" productCost productAmount (Just (Offer 1 "3 for 130" 3 20 False offerReduction 0))
                        , Product 2 1 "B" productCost productAmount Nothing
                        ]

                    expected =
                        ((productAmount * productCost) - offerReduction) + (productAmount * productCost)

                    result =
                        Main.updatePrice products
                in
                Expect.equal expected result
        , fuzz2 (intRange 0 99) (intRange 0 10) "returns 0 when there are offers and the price is always lower than the maximum offer reduction" <|
            \productAmount productCost ->
                let
                    offerReduction =
                        1000

                    products =
                        [ Product 1 0 "A" productCost productAmount (Just (Offer 1 "3 for 130" 3 20 False offerReduction 0))
                        , Product 2 1 "B" productCost productAmount (Just (Offer 1 "3 for 130" 3 20 False offerReduction 0))
                        ]

                    expected =
                        0

                    result =
                        Main.updatePrice products
                in
                Expect.equal expected result
        ]
