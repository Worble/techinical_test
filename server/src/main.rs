extern crate actix_web;
#[macro_use]
extern crate serde_derive;
extern crate env_logger;
use actix_web::middleware::cors;
use actix_web::middleware::Logger;
use actix_web::{http::Method, server, App, HttpRequest, Json, Result};

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

fn index(_req: &HttpRequest) -> &'static str {
    "Hello world!"
}

fn main() {
    let address = "127.0.0.1:8088";
    println!("Hosting server on: {}", address);

    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();

    server::new(|| {
        App::new()
            .middleware(Logger::default())
            .middleware(
                cors::Cors::build()
                    .allowed_methods(vec!["GET"])
                    .allowed_origin("http://localhost:8080")
                    .finish(),
            )
            .resource("/", |r| r.f(index))
            .resource(r"/api/data", |r| r.method(Method::GET).f(get_all_products))
    })
    .bind(address)
    .unwrap()
    .run();
}
