# Docker integration database

This fixture builds a single container with MySQL 8.0 and PostgreSQL 18 for local
integration testing.

## Build

```bash
docker build -t pg-chameleon-integration tests/docker
```

## Run

```bash
docker run --rm --name pg-chameleon-integration \
  -p 3306:3306 -p 5432:5432 \
  pg-chameleon-integration
```

The container seeds:

- MySQL `sakila` on `localhost:3306` with `usr_test` / `test`
- PostgreSQL `db_test` on `localhost:5432` with `usr_test` / `test`

The MySQL seed includes a `customer.notes` value with an ASCII NUL byte to
exercise the NUL-stripping path.

## Smoke Test

```bash
tests/docker/smoke.sh
```

The smoke test starts the image, waits until both databases are seeded, then
checks the MySQL sample rows, the NUL-byte fixture, and the PostgreSQL 18 server.
