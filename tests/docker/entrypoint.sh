#!/usr/bin/env bash
set -euo pipefail

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

pg_ctlcluster 18 main start
service mysql start

until mysqladmin ping --silent; do
    sleep 1
done

until pg_isready -h localhost -p 5432 >/dev/null 2>&1; do
    sleep 1
done

mysql --protocol=socket -uroot < /docker-entrypoint-initdb.d/mysql-seed.sql
runuser -u postgres -- psql -v ON_ERROR_STOP=1 -f /docker-entrypoint-initdb.d/postgres-seed.sql

echo "Integration databases are ready."
echo "MySQL:      localhost:3306 user=usr_test password=test database=sakila"
echo "PostgreSQL: localhost:5432 user=usr_test password=test database=db_test"

trap 'service mysql stop; pg_ctlcluster 18 main stop; exit 0' TERM INT
tail -F /var/log/mysql/error.log /var/log/postgresql/postgresql-18-main.log &
wait $!
