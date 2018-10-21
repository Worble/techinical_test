{-
   In Elm, our Main.elm file is the entrypoint to our application. Since we only have a single page with some minor logic,
   it is also our only file! If you're initially concerned about the length of this file, I recommend reading
   https://guide.elm-lang.org/webapps/structure.html for a quick overview on how Elm projects should be structured, and
   why file length shouldn't be a concern when building applications.
-}
-- We expose these methods in Main for testing purposes


module Main exposing (Offer, OrderBy(..), Ordering, Product, ProductUpdate(..), getProduct, main, orderProducts, subscriptions, update, updateOffer, updatePrice, updateProductAmount, updateProductList)

import Browser
import Html exposing (Html, a, button, div, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy)
import Http
import Json.Decode as Decode exposing (Decoder, int, list, nullable, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Url.Builder as Url


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { products : List Product
    , totalPrice : Int
    , productOrder : Ordering
    }


type alias Ordering =
    { orderBy : OrderBy
    , orderReverse : Bool
    }


type alias Product =
    { id : Int
    , ordinal : Int
    , name : String
    , price : Int
    , amountInBasket : Int
    , offer : Maybe Offer
    , totalPrice : Int
    }


type alias Offer =
    { id : Int
    , text : String
    , basketAmount : Int
    , subtractAmount : Int
    , currentlyActive : Bool
    , totalAmountToSubtract : Int
    , timesCurrentlyActive : Int
    }



-- For now we're just passing hard coded products into the model


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model [] 0 (Ordering Default False)
    , getData
    )



-- HTTP


getData : Cmd Msg
getData =
    Http.send GetProductsData (Http.get dataUrl (list productDecoder))


dataUrl : String
dataUrl =
    Url.crossOrigin "http://localhost:8088" [ "api", "data" ] []


productDecoder : Decoder Product
productDecoder =
    Decode.succeed Product
        |> required "id" int
        |> required "ordinal" int
        |> required "name" string
        |> required "price" int
        |> hardcoded 0
        |> optional "offer" (nullable offerDecoder) Nothing
        |> hardcoded 0


offerDecoder : Decoder Offer
offerDecoder =
    Decode.succeed Offer
        |> required "id" int
        |> required "text" string
        |> required "basket_amount" int
        |> required "subtract_amount" int
        |> hardcoded False
        |> hardcoded 0
        |> hardcoded 0



-- UPDATE


type OrderBy
    = Default
    | Name
    | Price


type ProductUpdate
    = Increment
    | Decrement


type Msg
    = NoOp
    | UpdateProduct ProductUpdate Int Int
    | GetProductsData (Result Http.Error (List Product))
    | ChangeOrder OrderBy


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateProduct updateType id amount ->
            let
                productToUpdate =
                    getProduct id model.products

                updatedProduct =
                    case productToUpdate of
                        Just product ->
                            Just (updateProductAmount updateType product amount)

                        Nothing ->
                            Nothing

                updatedProducts =
                    case updatedProduct of
                        Just product ->
                            updateProductList product model.products

                        Nothing ->
                            model.products

                updatedPrice =
                    updatePrice updatedProducts
            in
            ( { model | products = updatedProducts, totalPrice = updatedPrice }, Cmd.none )

        GetProductsData response ->
            case response of
                Ok products ->
                    ( { model | products = products }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ChangeOrder orderBy ->
            let
                reverse =
                    if model.productOrder.orderBy == orderBy then
                        not model.productOrder.orderReverse

                    else
                        model.productOrder.orderReverse

                oldProductOrder =
                    model.productOrder

                newProductOrder =
                    { oldProductOrder | orderReverse = reverse, orderBy = orderBy }
            in
            ( { model | productOrder = newProductOrder }, Cmd.none )


orderProducts : List Product -> Ordering -> List Product
orderProducts products productOrdering =
    let
        sortedList =
            case productOrdering.orderBy of
                Default ->
                    List.sortBy .ordinal products

                Name ->
                    List.sortBy .name products

                Price ->
                    List.sortBy .price products
    in
    if productOrdering.orderReverse then
        List.reverse sortedList

    else
        sortedList



--Just a quick helper function to find a specific product based on its id using recursion


getProduct : Int -> List Product -> Maybe Product
getProduct id products =
    let
        head =
            List.head products
    in
    case head of
        Just product ->
            if product.id == id then
                Just product

            else
                case List.tail products of
                    Just tail ->
                        getProduct id tail

                    Nothing ->
                        Nothing

        Nothing ->
            Nothing



--Returns a new product by either incrementing or decrementing the old one by a given amount


updateProductAmount : ProductUpdate -> Product -> Int -> Product
updateProductAmount updateType product amount =
    case updateType of
        Increment ->
            incrementProduct product amount

        Decrement ->
            derementProduct product amount


incrementProduct : Product -> Int -> Product
incrementProduct product amount =
    let
        newAmount =
            product.amountInBasket + amount

        oldOffer =
            product.offer

        newOffer =
            case oldOffer of
                Just offer ->
                    Just (updateOffer newAmount offer)

                Nothing ->
                    Nothing

        newPrice =
            calculateProductCost product.price newAmount newOffer
    in
    { product | amountInBasket = newAmount, offer = newOffer, totalPrice = newPrice }


derementProduct : Product -> Int -> Product
derementProduct product amount =
    let
        newAmount =
            let
                currentAmount =
                    product.amountInBasket - amount
            in
            if currentAmount < 0 then
                0

            else
                currentAmount

        oldOffer =
            product.offer

        newOffer =
            case oldOffer of
                Just offer ->
                    Just (updateOffer newAmount offer)

                Nothing ->
                    Nothing

        newPrice =
            calculateProductCost product.price newAmount newOffer
    in
    { product | amountInBasket = newAmount, offer = newOffer, totalPrice = newPrice }


calculateProductCost : Int -> Int -> Maybe Offer -> Int
calculateProductCost cost amount maybeOffer =
    let
        price =
            cost * amount
    in
    case maybeOffer of
        Just offer ->
            let
                newPrice =
                    price - offer.totalAmountToSubtract
            in
            if newPrice < 0 then
                0

            else
                newPrice

        Nothing ->
            price



--Updates the offer given the new amount in the basket and determines whether or it is active, and how much is currently saved


updateOffer : Int -> Offer -> Offer
updateOffer newBasketAmount offer =
    if newBasketAmount >= offer.basketAmount then
        let
            timesActive =
                newBasketAmount // offer.basketAmount

            priceReduction =
                timesActive * offer.subtractAmount
        in
        { offer | currentlyActive = True, totalAmountToSubtract = priceReduction, timesCurrentlyActive = timesActive }

    else
        { offer | currentlyActive = False, totalAmountToSubtract = 0, timesCurrentlyActive = 0 }



--A quick helper function to return a new list of products with the given product replacing the one in the list with the same id


updateProductList : Product -> List Product -> List Product
updateProductList updatedProduct productList =
    List.map
        (\p ->
            if p.id == updatedProduct.id then
                updatedProduct

            else
                p
        )
        productList



--For each product, take the price and times it by the amount in the basket. If an offer is currently active, deduct it from the total price


updatePrice : List Product -> Int
updatePrice products =
    List.map
        (\p ->
            calculateProductCost p.price p.amountInBasket p.offer
        )
        products
        |> List.sum



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW
{- Here we use `keyed.node "div"` on the products. In a situation where products are inserted, removed or reorganised, this would
   cut down on the amount of work the diffing tool within elm does by matching based on a key. This is premature optimisation for
   the purposes of demonstration.
-}


view : Model -> Html Msg
view model =
    div []
        [ div [ class "container grid-xl py-2" ]
            [ displayProductHeader
            , if List.length model.products > 0 then
                Keyed.node "div" [] (orderProducts model.products model.productOrder |> List.map displayProductKeyed)

              else
                div [] [ text "Loading data..." ]
            , div [] [ lazy displayPrice model ]
            ]
        ]


displayProductHeader : Html Msg
displayProductHeader =
    div [ class "columns py-2" ]
        [ div [ class "column col-2" ] [ a [ onClick (ChangeOrder Name) ] [ text "Name" ] ]
        , div [ class "column col-2" ] [ a [ onClick (ChangeOrder Price) ] [ text "Price" ] ]
        , div [ class "column col-2" ] []
        , div [ class "column col-2" ] [ text "Current Amount" ]
        , div [ class "column col-2" ] [ text "Total Price" ]
        , div [ class "column col-2" ] []
        ]



--Here we use the `lazy` function. This means that given a nodes parameters haven't changed, elm will skip building the virtual node and save on rendering time.


displayProductKeyed : Product -> ( String, Html Msg )
displayProductKeyed product =
    ( String.fromInt product.id
    , lazy displayProduct product
    )


displayProduct : Product -> Html Msg
displayProduct product =
    div [ class "columns py-2" ]
        [ div [ class "column col-2" ] [ text product.name ]
        , div [ class "column col-2" ] [ text <| String.fromInt product.price ]
        , div [ class "column col-2" ]
            [ div [] [ button [ class "btn btn-primary", onClick (UpdateProduct Increment product.id 1) ] [ text "Add to basket" ] ]
            , div [] [ button [ class "btn", onClick (UpdateProduct Decrement product.id 1) ] [ text "Remove from basket" ] ]
            ]
        , div [ class "column col-2" ]
            [ span [] [ text <| String.fromInt product.amountInBasket ]
            ]
        , div [ class "column col-2" ] [ text <| String.fromInt product.totalPrice ]
        , div [ class "column col-2" ]
            [ button [ class "btn", onClick (UpdateProduct Decrement product.id product.amountInBasket) ] [ text "Remove all" ] ]
        ]


displayPrice : Model -> Html Msg
displayPrice model =
    div [ class "columns py-2" ]
        [ div [ class "column col-6" ] (List.map (lazy displayOffers) model.products)
        , div [ class "column col-2" ] []
        , div [ class "column col-2" ] [ text <| String.fromInt model.totalPrice ]
        , div [ class "column col-2" ] []
        ]


displayOffers : Product -> Html Msg
displayOffers product =
    case product.offer of
        Just offer ->
            if offer.currentlyActive then
                div []
                    [ div [] [ text ("Offer active: " ++ offer.text ++ " x" ++ String.fromInt offer.timesCurrentlyActive ++ " saving " ++ String.fromInt offer.totalAmountToSubtract) ]
                    ]

            else
                text ""

        Nothing ->
            text ""
