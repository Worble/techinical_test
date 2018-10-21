module GetProductAmountTests exposing (getProductAmountTests)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, intRange)
import Main exposing (Offer, Product)
import Random
import Test exposing (..)


getProductAmountTests : Test
getProductAmountTests =
    describe "updateProductAmount"
        [ fuzz int "increases the product amount by the specified amount when passed type Increment" <|
            \amount ->
                let
                    product =
                        Product 1 2 "C" 20 0 Nothing

                    result =
                        Main.updateProductAmount Main.Increment product amount
                in
                Expect.equal amount result.amountInBasket
        , fuzz2 int int "increases the product amount by the specified amount when passed type Increment and the product already has an amount set" <|
            \increaseAmount currentAmount ->
                let
                    expected =
                        increaseAmount + currentAmount

                    product =
                        Product 1 2 "C" 20 currentAmount Nothing

                    result =
                        Main.updateProductAmount Main.Increment product increaseAmount
                in
                Expect.equal expected result.amountInBasket
        , fuzz2 (intRange 0 999) (intRange 1000 Random.maxInt) "decreases the amount by the specified amount when passed type Decrement" <|
            \decreaseAmount currentAmount ->
                let
                    expected =
                        currentAmount - decreaseAmount

                    product =
                        Product 1 2 "C" 20 currentAmount Nothing

                    result =
                        Main.updateProductAmount Main.Decrement product decreaseAmount
                in
                Expect.equal expected result.amountInBasket
        , fuzz2 (intRange 1000 Random.maxInt) (intRange 0 999) "decreases the amount to zero when passed type Decrement and decrease is larger than current amount" <|
            \decreaseAmount currentAmount ->
                let
                    expected =
                        0

                    product =
                        Product 1 2 "C" 20 currentAmount Nothing

                    result =
                        Main.updateProductAmount Main.Decrement product decreaseAmount
                in
                Expect.equal expected result.amountInBasket
        ]
