-- Create _realtime schema (with underscore for Realtime service)
CREATE SCHEMA IF NOT EXISTS _realtime;

-- Grant usage to postgres user
GRANT USAGE ON SCHEMA _realtime TO postgres;
GRANT CREATE ON SCHEMA _realtime TO postgres;

-- Create extension in _realtime schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA _realtime;

-- Create schema_migrations table for _realtime
CREATE TABLE IF NOT EXISTS _realtime.schema_migrations (
    version VARCHAR(14) NOT NULL PRIMARY KEY
);

-- Create unique index
CREATE UNIQUE INDEX IF NOT EXISTS schema_migrations_version_idx ON _realtime.schema_migrations (version);