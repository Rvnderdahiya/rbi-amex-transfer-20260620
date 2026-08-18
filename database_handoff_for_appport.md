# Database Handoff For Appport/APCOT

## Why This File Exists

The local prototype uses SQLAlchemy to define and create database tables. If SQLAlchemy is blocked or quarantined in the AmEx hosting environment, the Appport/APCOT team can recreate the same data model using plain SQL and a different approved database layer.

## Source Files Used To Create The Local DB

The original local database structure comes from:

```text
backend/app/models.py
backend/app/database.py
backend/app/schemas.py
docs/data_dictionary.md
```

The local SQLite database file is not required for deployment. It only contains fake local test data.

## Recommended Quick Path

If SQLAlchemy is not allowed, the fastest safe port is:

1. Use the plain schema in `docs/duckdb_schema.sql` to create the tables.
2. Replace SQLAlchemy ORM calls with an approved DB access layer.
3. Keep the same API request/response shapes from `backend/app/schemas.py`.
4. Keep the same no-crawling/no-scraping policy.
5. Do not connect `/internal-match` to ChatGPT Actions.

## Important Note On DuckDB

DuckDB can be used for a prototype or local embedded database, but it is usually better for analytics than concurrent transactional API workloads. If multiple users will write records at the same time, an AmEx-approved Postgres-style service or approved transactional database is preferable.

For a quick Appport demo, DuckDB is acceptable if Appport approves it and expected traffic is low.

## Tables Needed

- `runs`
- `candidates`
- `extracted_signals`
- `evidence`
- `acceptance_reviews`
- `internal_linkage_packs`
- `reports`

The local fake `internal_match_results` table exists in the prototype, but for Option A it should not be used by Custom GPT Actions. Internal matching should remain a separate AmEx-controlled solution.
