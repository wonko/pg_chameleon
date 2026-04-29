DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usr_test') THEN
        CREATE ROLE usr_test LOGIN PASSWORD 'test';
    END IF;
END
$$;

SELECT 'CREATE DATABASE db_test OWNER usr_test'
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'db_test')\gexec
