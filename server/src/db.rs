extern crate actix;
use actix::prelude::{Actor, Handler, Message, SyncContext};
use actix_web::*;
use diesel::prelude::*;
use diesel::r2d2::{ConnectionManager, Pool};

use crate::models;
use crate::schema;

/// This is db executor actor. We are going to run 3 of them in parallel.
pub struct DbExecutor(pub Pool<ConnectionManager<SqliteConnection>>);

/// This is only message that this actor can handle, but it is easy to extend
/// number of messages.
pub struct GetAllProducts {}

impl Message for GetAllProducts {
    type Result = Result<Vec<(models::Product, Option<models::Offer>)>, Error>;
}

impl Actor for DbExecutor {
    type Context = SyncContext<Self>;
}

impl Handler<GetAllProducts> for DbExecutor {
    type Result = Result<Vec<(models::Product, Option<models::Offer>)>, Error>;

    fn handle(&mut self, _msg: GetAllProducts, _: &mut Self::Context) -> Self::Result {
        use self::schema::offers::dsl::*;
        use self::schema::products::dsl::*;

        let conn: &SqliteConnection = &self.0.get().unwrap();

        let items = products
            .left_join(offers)
            .load::<(models::Product, Option<models::Offer>)>(conn)
            .map_err(|_| error::ErrorInternalServerError("Error loading products"))?;

        Ok(items)
    }
}
