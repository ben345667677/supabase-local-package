-- Create auth schema
CREATE SCHEMA IF NOT EXISTS auth;

-- Create extensions in auth schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA auth;
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA auth;

-- Create schema_migrations table for auth
CREATE TABLE IF NOT EXISTS auth.schema_migrations (
    version VARCHAR(14) NOT NULL PRIMARY KEY
);

-- Create unique index
CREATE UNIQUE INDEX IF NOT EXISTS schema_migrations_version_idx ON auth.schema_migrations (version);