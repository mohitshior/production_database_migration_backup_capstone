# Production Database Migration & Backup Strategy Capstone

A PostgreSQL production-style database project demonstrating:

- Version-controlled database migrations with **up/down** scripts
- Stored procedures for operational workflows
- Database triggers for automated audit logging
- Materialized views for frequently used analytical queries
- Backup, restore, disaster-recovery and rollback documentation
- Verification scripts for checking the complete setup

## Technology

- PostgreSQL 14+
- SQL
- `psql`
- `pg_dump` / `pg_restore`

## Project Structure

```text
production_database_migration_backup_capstone/
├── migrations/
│   ├── 001_create_core_schema.up.sql
│   ├── 001_create_core_schema.down.sql
│   ├── 002_create_audit_system.up.sql
│   ├── 002_create_audit_system.down.sql
│   ├── 003_create_analytics.up.sql
│   └── 003_create_analytics.down.sql
├── procedures/
│   └── procedures.sql
├── triggers/
│   └── audit_triggers.sql
├── views/
│   └── materialized_views.sql
├── scripts/
│   ├── seed_data.sql
│   ├── refresh_materialized_views.sql
│   ├── verify_project.sql
│   ├── backup_database.bat
│   └── restore_database.bat
├── docs/
│   └── DISASTER_RECOVERY.md
├── run_all.sql
└── README.md
```

## Database Model

The sample production database is an e-commerce/order-processing system:

- `customers` — customer master data
- `products` — product catalog and stock
- `orders` — customer orders
- `order_items` — items belonging to orders
- `audit_log` — automatic change history

Relationships:

```text
customers 1 ──────── N orders
orders    1 ──────── N order_items
products  1 ──────── N order_items
```

## Quick Start

Create a database:

```sql
CREATE DATABASE production_capstone;
```

Then connect to it:

```bash
psql -U postgres -d production_capstone
```

Run the complete setup:

```sql
\i 'C:/path/to/production_database_migration_backup_capstone/run_all.sql'
```

Or from PowerShell:

```powershell
psql -U postgres -d production_capstone -f ".\run_all.sql"
```

The project is designed to be safe to run on a fresh database.

## Migration Strategy

Each migration has two files:

- `.up.sql` — applies the schema change
- `.down.sql` — reverses the schema change

Example:

```text
001_create_core_schema.up.sql
001_create_core_schema.down.sql
```

The migration order is:

1. Core tables and indexes
2. Audit table, audit function and triggers
3. Materialized analytical views

In a real production deployment, a migration tool such as Flyway, Liquibase, Prisma Migrate, or a CI/CD migration job can execute these files in order.

## Stored Procedures

The project includes:

- `create_customer(...)`
- `create_order(...)`
- `add_order_item(...)`
- `change_product_stock(...)`

These procedures centralize important business operations and use transactions/validation where appropriate.

## Audit Logging

Triggers automatically write changes to `audit_log` for:

- `customers`
- `products`
- `orders`
- `order_items`

The audit record stores:

- table name
- operation (`INSERT`, `UPDATE`, `DELETE`)
- row identifier
- old row as JSON
- new row as JSON
- database user
- timestamp

Test it with:

```sql
UPDATE products
SET price = price + 100
WHERE product_id = 1;

SELECT *
FROM audit_log
ORDER BY audit_id DESC;
```

## Materialized Views

Two materialized views are provided:

1. `mv_customer_order_summary`
2. `mv_product_sales_summary`

Refresh them with:

```sql
CALL refresh_analytics_views();
```

Or:

```sql
REFRESH MATERIALIZED VIEW mv_customer_order_summary;
REFRESH MATERIALIZED VIEW mv_product_sales_summary;
```

Materialized views are useful when the same analytical query is executed frequently and slightly stale data is acceptable.

## Backup

A custom-format PostgreSQL backup can be created with:

```bash
pg_dump -U postgres -d production_capstone -F c -f production_capstone_backup.dump
```

A plain SQL backup:

```bash
pg_dump -U postgres -d production_capstone -F p -f production_capstone_backup.sql
```

The supplied Windows scripts use `pg_dump` and `pg_restore`.

## Restore

For a custom-format dump:

```bash
pg_restore -U postgres -d production_capstone --clean --if-exists production_capstone_backup.dump
```

For a plain SQL dump:

```bash
psql -U postgres -d production_capstone -f production_capstone_backup.sql
```

## Disaster Recovery Strategy

The recommended strategy is:

- Full daily backup
- More frequent backups/WAL archiving for a higher-availability production system
- Store backups outside the database server
- Encrypt backups at rest
- Restrict backup access
- Periodically test restores
- Keep multiple backup generations
- Document RPO and RTO

See `docs/DISASTER_RECOVERY.md`.

## Verification

Run:

```sql
\i 'scripts/verify_project.sql'
```

The verification script checks:

- expected tables
- procedures/functions
- triggers
- materialized views
- row counts
- audit logging
- analytical view output

## Submission Proof

For the capstone submission, a useful demonstration video/screenshots can show:

1. Repository/folder structure
2. Migration up/down files
3. Successful `run_all.sql`
4. `\dt` showing tables
5. Trigger-generated audit row
6. Materialized view query
7. Backup command/output
8. Restore/verification process
9. GitHub repository containing the complete project

## Production Note

This is an educational capstone. Before using a design like this in a real production environment, add organization-specific security, secrets management, monitoring, backup retention, point-in-time recovery, replication/high availability, migration locking, CI/CD controls and tested operational runbooks.
