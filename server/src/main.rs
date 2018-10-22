extern crate actix_web;
#[macro_use]
extern crate serde_derive;
extern crate env_logger;
use actix_web::middleware::cors;
use actix_web::middleware::Logger;
use actix_web::{
    http, http::Method, middleware, server, App, AsyncResponder, FutureResponse, HttpRequest,
    HttpResponse, Json, Path, Result, State,
};
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
struct Product {
    id: i32,
    ordinal: i32,
    name: String,
    price: i32,
    offer: Option<Offer>,
}

#[derive(Serialize)]
struct Offer {
    id: i32,
    text: String,
    basket_amount: i32,
    subtract_amount: i32,
}

fn get_all_products(_req: &HttpRequest) -> Result<Json<Vec<Product>>> {
    let products = vec![
        Product {
            id: 1,
            ordinal: 0,
            name: String::from("A"),
            price: 50,
            offer: Some(Offer {
                id: 1,
                text: String::from("3 for 130"),
                basket_amount: 3,
                subtract_amount: 20,
            }),
        },
        Product {
            id: 2,
            ordinal: 1,
            name: String::from("B"),
            price: 30,
            offer: Some(Offer {
                id: 2,
                text: String::from("2 for 45"),
                basket_amount: 2,
                subtract_amount: 15,
            }),
        },
        Product {
            id: 3,
            ordinal: 2,
            name: String::from("C"),
            price: 20,
            offer: None,
        },
        Product {
            id: 4,
            ordinal: 3,
            name: String::from("D"),
            price: 15,
            offer: None,
        },
    ];

    Ok(Json(products))
}

fn get_all_products_diesel(state: State<AppState>) -> FutureResponse<HttpResponse> {
    // send async `CreateUser` message to a `DbExecutor`
    state
        .db
        .send(GetAllProducts {})
        .from_err()
        .and_then(|res| match res {
            Ok(products) => Ok(HttpResponse::Ok().json(products)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn index(_req: &HttpRequest) -> &'static str {
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
            //.resource("/", |r| r.f(index))
            //.resource(r"/api/data", |r| r.method(Method::GET).f(get_all_products))
            .resource(r"/api/data2", |r| {
                r.method(Method::GET).with(get_all_products_diesel)
            })
    })
    .bind(address)
    .unwrap()
    .start();

    let _ = sys.run();
}
