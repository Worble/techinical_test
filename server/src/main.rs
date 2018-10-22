extern crate actix_web;
#[macro_use]
extern crate serde_derive;
extern crate env_logger;
use actix_web::middleware::cors;
use actix_web::middleware::Logger;
use actix_web::{http::Method, server, App, AsyncResponder, FutureResponse, HttpResponse, State};
extern crate serde;
#[macro_use]
extern crate diesel;
extern crate actix;
extern crate futures;
extern crate r2d2;

use actix::prelude::*;

use diesel::prelude::*;
use diesel::r2d2::ConnectionManager;
use futures::Future;

mod db;
pub mod models;
pub mod schema;
use self::db::{DbExecutor, GetAllProducts};

struct AppState {
    db: Addr<DbExecutor>,
}

#[derive(Serialize)]
struct ProductJson {
    id: i32,
    ordinal: i32,
    name: String,
    price: i32,
    offer: Option<OfferJson>,
}

#[derive(Serialize)]
struct OfferJson {
    id: i32,
    text: String,
    basket_amount: i32,
    subtract_amount: i32,
}

fn build_offer_json(offer: models::Offer) -> OfferJson {
    OfferJson {
        id: offer.id,
        text: offer.text,
        basket_amount: offer.basket_amount,
        subtract_amount: offer.subtract_amount,
    }
}

fn build_product_json((product, offer): (models::Product, Option<models::Offer>)) -> ProductJson {
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

fn get_all_products_diesel(state: State<AppState>) -> FutureResponse<HttpResponse> {
    // send async `CreateUser` message to a `DbExecutor`
    state
        .db
        .send(GetAllProducts {})
        .from_err()
        .and_then(|res| match res {
            Ok(products) => {
                let mut products_json: Vec<ProductJson> = vec![];
                for product in products {
                    products_json.push(build_product_json(product))
                }
                Ok(HttpResponse::Ok().json(products_json))
            }
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn index(_state: State<AppState>) -> &'static str {
    "Hello world!"
}

fn main() {
    let address = "127.0.0.1:8088";
    println!("Hosting server on: {}", address);

    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();

    let sys = actix::System::new("diesel-example");

    // Start 3 db executor actors
    let manager = ConnectionManager::<SqliteConnection>::new("test.db");
    let pool = r2d2::Pool::builder()
        .build(manager)
        .expect("Failed to create pool.");

    let addr = SyncArbiter::start(3, move || DbExecutor(pool.clone()));

    server::new(move || {
        App::with_state(AppState { db: addr.clone() })
            .middleware(Logger::default())
            .middleware(
                cors::Cors::build()
                    .allowed_methods(vec!["GET"])
                    .allowed_origin("http://localhost:8080")
                    .finish(),
            )
            .resource("/", |r| r.with(index))
            //.resource(r"/api/data", |r| r.method(Method::GET).f(get_all_products))
            .resource(r"/api/data", |r| {
                r.method(Method::GET).with(get_all_products_diesel)
            })
    })
    .bind(address)
    .unwrap()
    .start();

    let _ = sys.run();
}
