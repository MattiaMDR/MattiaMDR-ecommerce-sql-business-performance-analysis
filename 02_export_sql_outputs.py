from pathlib import Path
import sqlite3

import pandas as pd

database_path = Path("database/olist_ecommerce.db")
sql_dir = Path("sql")
output_dir = Path("outputs")


def export_query(connection, sql_path):
    query = sql_path.read_text(encoding="utf-8")
    output_frame = pd.read_sql_query(query, connection)
    output_path = output_dir / f"{sql_path.stem}.csv"
    output_frame.to_csv(output_path, index=False)
    print(f"{output_path}: {len(output_frame):,} rows")


def main():
    if not database_path.exists():
        raise FileNotFoundError(f"{database_path} not found")

    output_dir.mkdir(exist_ok=True)

    with sqlite3.connect(database_path) as connection:
        for sql_path in sorted(sql_dir.glob("*.sql")):
            export_query(connection, sql_path)


if __name__ == "__main__":
    main()
