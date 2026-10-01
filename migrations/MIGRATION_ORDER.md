# Migration Order

Run in this order:

1. `001_create_core_schema.up.sql`
2. `002_create_audit_system.up.sql`
3. `003_create_analytics.up.sql`

For rollback, reverse the order:

1. `003_create_analytics.down.sql`
2. `002_create_audit_system.down.sql`
3. `001_create_core_schema.down.sql`
