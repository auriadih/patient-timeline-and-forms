

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname = 'DATABASE_NAME';

drop database DATABASE_NAME;
create database DATABASE_NAME;
\c DATABASE_NAME;
create extension pgcrypto;
\q
