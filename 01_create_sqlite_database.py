from pathlib import Path
import sqlite3
import zipfile

import pandas as pd

zip_path = Path("archive (8).zip")
raw_dir = Path("data_raw")
database_dir = Path("database")
database_path = database_dir / "olist_ecommerce.db"

table_files = {
    "olist_customers": "olist_customers_dataset.csv",
    "olist_orders": "olist_orders_dataset.csv",
    "olist_order_items": "olist_order_items_dataset.csv",
    "olist_order_payments": "olist_order_payments_dataset.csv",
    "olist_order_reviews": "olist_order_reviews_dataset.csv",
    "olist_products": "olist_products_dataset.csv",
    "olist_sellers": "olist_sellers_dataset.csv",
    "product_category_translation": "product_category_name_translation.csv",
}

indexes = """
CREATE INDEX IF NOT EXISTS idx_orders_order_id ON olist_orders(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON olist_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON olist_orders(order_status);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON olist_order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON olist_order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_seller_id ON olist_order_items(seller_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON olist_order_payments(order_id);
CREATE INDEX IF NOT EXISTS idx_reviews_order_id ON olist_order_reviews(order_id);
CREATE INDEX IF NOT EXISTS idx_customers_customer_id ON olist_customers(customer_id);
CREATE INDEX IF NOT EXISTS idx_products_product_id ON olist_products(product_id);
CREATE INDEX IF NOT EXISTS idx_sellers_seller_id ON olist_sellers(seller_id);
"""


def extract_source_files():
    raw_dir.mkdir(exist_ok=True)

    with zipfile.ZipFile(zip_path, "r") as archive:
        for csv_name in table_files.values():
            archive.extract(csv_name, raw_dir)


def load_csv_tables(connection):
    for table_name, csv_name in table_files.items():
        csv_path = raw_dir / csv_name
        table_frame = pd.read_csv(csv_path, low_memory=False)
        table_frame.to_sql(table_name, connection, if_exists="replace", index=False)
        print(f"{table_name}: {len(table_frame):,} rows")


def create_indexes(connection):
    connection.executescript(indexes)
    connection.commit()


def main():
    if not zip_path.exists():
        raise FileNotFoundError(f"{zip_path} not found")

    database_dir.mkdir(exist_ok=True)
    extract_source_files()

    with sqlite3.connect(database_path) as connection:
        load_csv_tables(connection)
        create_indexes(connection)

    print(f"database/{database_path.name}")


if __name__ == "__main__":
    main()
