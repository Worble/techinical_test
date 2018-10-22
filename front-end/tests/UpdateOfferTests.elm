module UpdateOfferTests exposing (updateOfferTests)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, intRange)
import Main exposing (Offer, Product)
import Random
import Test exposing (..)


updateOfferTests : Test
updateOfferTests =
    describe "updateOffer"
        [ fuzz2 (intRange 1000 Random.maxInt) (intRange 0 999) "activates offer when basket amount is greater than activation amount" <|
            \amount activationAmount ->
                let
                    offer =
                        Offer 1 "2 for 45" activationAmount 15 False 0 0

                    result =
                        Main.updateOffer amount offer
                in
                Expect.true "Expected offer to be active" result.currentlyActive
        , fuzz2 (intRange 0 999) (intRange 1000 Random.maxInt) "does not activate offer when basket amount is less than activation amount" <|
            \amount activationAmount ->
                let
                    offer =
                        Offer 1 "2 for 45" activationAmount 15 False 0 0

                    result =
                        Main.updateOffer amount offer
                in
                Expect.false "Expected offer to be inactive" result.currentlyActive
        , fuzz2 (intRange 1000 Random.maxInt) (intRange 0 999) "returned products timesCurrentlyActive is amount divided by activation amount when amount is greater than activation amount" <|
            \amount activationAmount ->
                let
                    offer =
                        Offer 1 "2 for 45" activationAmount 15 False 0 0

                    expected =
                        amount // activationAmount

                    result =
                        Main.updateOffer amount offer
                in
                Expect.equal expected result.timesCurrentlyActive
        , fuzz2 (intRange 0 999) (intRange 1000 Random.maxInt) "returned products timesCurrentlyActive is 0 when activation amount is greater than amount" <|
            \amount activationAmount ->
                let
                    offer =
                        Offer 1 "2 for 45" activationAmount 15 False 0 0

                    expected =
                        0

                    result =
                        Main.updateOffer amount offer
                in
                Expect.equal expected result.timesCurrentlyActive
        , fuzz3 (intRange 1000 Random.maxInt) (intRange 0 999) int "return products totalAmountToSubtract is times active x subtractAmount when amount is greater than activation amount" <|
            \amount activationAmount subtractAmount ->
                let
                    offer =
                        Offer 1 "2 for 45" activationAmount subtractAmount False 0 0

                    timesActive =
                        amount // activationAmount

                    expected =
                        subtractAmount * timesActive

                    result =
                        Main.updateOffer amount offer
                in
                Expect.equal expected result.totalAmountToSubtract
        , fuzz3 (intRange 0 999) (intRange 1000 Random.maxInt) int "return products totalAmountToSubtract is 0 when amount is greater than activation amount" <|
            \amount activationAmount subtractAmount ->
                let
                    offer =
                        Offer 1 "2 for 45" activationAmount subtractAmount False 0 0

                    expected =
                        0

                    result =
                        Main.updateOffer amount offer
                in
                Expect.equal expected result.totalAmountToSubtract
        ]
