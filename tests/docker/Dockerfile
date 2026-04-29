FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg lsb-release locales \
    && install -d /usr/share/postgresql-common/pgdg \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.gpg \
    && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends mysql-server postgresql-18 postgresql-client-18 \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/^# *listen_addresses = .*/listen_addresses = '*'/" /etc/postgresql/18/main/postgresql.conf \
    && printf '\nhost all all 0.0.0.0/0 scram-sha-256\nhost all all ::/0 scram-sha-256\n' >> /etc/postgresql/18/main/pg_hba.conf \
    && printf '[mysqld]\nbind-address=0.0.0.0\nserver-id=1\nlog-bin=mysql-bin\nbinlog-format=ROW\nbinlog-row-image=FULL\ngtid-mode=ON\nenforce-gtid-consistency=ON\n' \
        > /etc/mysql/mysql.conf.d/pg-chameleon.cnf

COPY entrypoint.sh /usr/local/bin/pg-chameleon-integration-entrypoint
COPY mysql-seed.sql /docker-entrypoint-initdb.d/mysql-seed.sql
COPY postgres-seed.sql /docker-entrypoint-initdb.d/postgres-seed.sql

RUN chmod +x /usr/local/bin/pg-chameleon-integration-entrypoint

EXPOSE 3306 5432

ENTRYPOINT ["/usr/local/bin/pg-chameleon-integration-entrypoint"]
