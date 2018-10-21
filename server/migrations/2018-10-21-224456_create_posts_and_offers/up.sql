CREATE TABLE offers (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "text" VARCHAR NOT NULL,
    "basket_amount" INTEGER NOT NULL,
    "subtract_amount" INTEGER NOT NULL
);

CREATE TABLE products (
    "id" INTEGER PRIMARY KEY NOT NULL,
    "ordinal" INTEGER NOT NULL,
    "name" VARCHAR NOT NULL,
    "price" INTEGER NOT NULL,
    "offer_id" INTEGER,
    FOREIGN KEY ("offer_id") REFERENCES offers("id")
);  