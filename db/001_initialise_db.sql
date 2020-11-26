

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname = 'timeline_and_forms';

drop database if exists timeline_and_forms;
create database timeline_and_forms;
grant all on database timeline_and_forms to auria;
\c timeline_and_forms;
create extension pgcrypto;
\q
