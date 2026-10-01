-- ============================================================
-- Production Database Migration & Backup Strategy Capstone
-- Complete fresh-database setup
-- PostgreSQL
-- ============================================================

\echo '=== MIGRATION 001: CORE SCHEMA ==='
\i migrations/001_create_core_schema.up.sql

\echo '=== MIGRATION 002: AUDIT SYSTEM ==='
\i migrations/002_create_audit_system.up.sql

\echo '=== PROCEDURES ==='
\i procedures/procedures.sql

\echo '=== MIGRATION 003: ANALYTICS ==='
\i migrations/003_create_analytics.up.sql

\echo '=== SEED DATA ==='
\i scripts/seed_data.sql

\echo '=== REFRESH ANALYTICS ==='
CALL refresh_analytics_views();

\echo '=== SETUP COMPLETE ==='
SELECT 'production_capstone database setup completed' AS status;
