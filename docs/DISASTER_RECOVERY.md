# Disaster Recovery & Backup Guide

## 1. Objective

The goal is to recover the PostgreSQL database after:

- accidental deletion
- corrupted data
- failed deployment
- server/storage failure
- application mistake
- database migration failure

This capstone demonstrates logical backups and documented recovery steps.

## 2. RPO and RTO

Example targets for planning:

- **RPO (Recovery Point Objective):** 24 hours for the educational setup
- **RTO (Recovery Time Objective):** 2 hours

A real production application should define these values based on business requirements.

## 3. Backup Types

### Logical backup

Custom format:

```bash
pg_dump -U postgres -d production_capstone -F c -f production_capstone_backup.dump
```

Plain SQL:

```bash
pg_dump -U postgres -d production_capstone -F p -f production_capstone_backup.sql
```

### Physical/PITR strategy

For a high-availability production system, use PostgreSQL base backups plus WAL archiving to support point-in-time recovery.

The exact implementation depends on the infrastructure and PostgreSQL deployment model.

## 4. Backup Retention

Example policy:

- Keep daily backups for 7 days
- Keep weekly backups for 4 weeks
- Keep monthly backups for 6 months

Retention should be adjusted to business and compliance requirements.

## 5. Backup Security

Backups should:

- be encrypted at rest
- use restricted credentials
- be stored separately from the primary database server
- be protected from accidental deletion
- be monitored for failures
- be periodically tested

Do not commit real database dumps, passwords or secrets to GitHub.

## 6. Restore Procedure

1. Stop or isolate applications that write to the database.
2. Create/prepare the target database.
3. Restore the backup.
4. Run verification queries.
5. Check important row counts.
6. Check application connectivity.
7. Resume application traffic.

Custom dump:

```bash
pg_restore -U postgres -d production_capstone --clean --if-exists production_capstone_backup.dump
```

Plain SQL:

```bash
psql -U postgres -d production_capstone -f production_capstone_backup.sql
```

## 7. Migration Failure / Rollback

Before a risky migration:

1. Take a backup.
2. Apply the migration in a controlled environment.
3. Run verification tests.
4. Apply it to production.
5. Monitor errors.

If a migration is designed to be reversible, run its matching `.down.sql` script.

Example:

```text
003_create_analytics.up.sql
003_create_analytics.down.sql
```

Rollback should be tested before production use.

## 8. Disaster Simulation

For a safe local demonstration:

1. Create a backup.
2. Verify the backup file exists.
3. Make a controlled schema/data change.
4. Restore the backup to a separate test database.
5. Compare row counts and important records.
6. Document the result.

Never perform destructive disaster tests against a real production database.

## 9. Monitoring Checklist

- Backup job success/failure
- Backup file size
- Backup age
- Disk capacity
- Database availability
- Replication/WAL health where applicable
- Restore test results
- Long-running queries
- Migration status

## 10. Final Recovery Checklist

```text
[ ] Identify incident
[ ] Stop further damage
[ ] Identify latest valid backup
[ ] Confirm recovery target
[ ] Restore to isolated environment when possible
[ ] Verify schema
[ ] Verify row counts
[ ] Verify critical records
[ ] Verify application connectivity
[ ] Resume service
[ ] Document incident and recovery result
```
