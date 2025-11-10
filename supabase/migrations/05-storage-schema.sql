-- Create storage schema
CREATE SCHEMA IF NOT EXISTS storage;

-- Create extensions in storage schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA storage;

-- Create schema_migrations table for storage
CREATE TABLE IF NOT EXISTS storage.schema_migrations (
    version VARCHAR(14) NOT NULL PRIMARY KEY
);

-- Create unique index
CREATE UNIQUE INDEX IF NOT EXISTS schema_migrations_version_idx ON storage.schema_migrations (version);