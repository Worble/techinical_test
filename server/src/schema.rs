table! {
    offers (id) {
        id -> Integer,
        text -> Text,
        basket_amount -> Integer,
        subtract_amount -> Integer,
    }
}

table! {
    products (id) {
        id -> Integer,
        ordinal -> Integer,
        name -> Text,
        price -> Integer,
        offer_id -> Nullable<Integer>,
    }
}

joinable!(products -> offers (offer_id));

allow_tables_to_appear_in_same_query!(
    offers,
    products,
);
