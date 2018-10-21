#[derive(Queryable)]
pub struct Offer {
    pub id: i32,
    pub text: String,
    pub basket_amount: i32,
    pub subtract_amount: i32,
}

#[derive(Queryable)]
pub struct Product {
    pub id: i32,
    pub ordinal: i32,
    pub name: String,
    pub price: i32,
    pub offer: Option<Offer>,
}
