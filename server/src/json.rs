use crate::models;

#[derive(Serialize)]
pub struct ProductJson {
    id: i32,
    ordinal: i32,
    name: String,
    price: i32,
    offer: Option<OfferJson>,
}

#[derive(Serialize)]
pub struct OfferJson {
    id: i32,
    text: String,
    basket_amount: i32,
    subtract_amount: i32,
}

pub fn build_offer_json(offer: models::Offer) -> OfferJson {
    OfferJson {
        id: offer.id,
        text: offer.text,
        basket_amount: offer.basket_amount,
        subtract_amount: offer.subtract_amount,
    }
}

pub fn build_product_json(
    (product, offer): (models::Product, Option<models::Offer>),
) -> ProductJson {
    let offer = match offer {
        Some(offer) => Some(build_offer_json(offer)),
        None => None,
    };
    ProductJson {
        id: product.id,
        ordinal: product.ordinal,
        name: product.name,
        price: product.price,
        offer: offer,
    }
}
