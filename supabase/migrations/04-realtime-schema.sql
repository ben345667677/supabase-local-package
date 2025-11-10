-- Create realtime schema
CREATE SCHEMA IF NOT EXISTS realtime;

-- Create extensions in realtime schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA realtime;

-- Create schema_migrations table for realtime
CREATE TABLE IF NOT EXISTS realtime.schema_migrations (
    version VARCHAR(14) NOT NULL PRIMARY KEY
);

-- Create unique index
CREATE UNIQUE INDEX IF NOT EXISTS schema_migrations_version_idx ON realtime.schema_migrations (version);