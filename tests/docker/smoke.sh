#!/usr/bin/env bash
set -euo pipefail

image="${PG_CHAMELEON_DOCKER_IMAGE:-pg-chameleon-integration}"
container="${PG_CHAMELEON_DOCKER_CONTAINER:-pg-chameleon-integration-smoke}"

cleanup() {
    docker rm -f "${container}" >/dev/null 2>&1 || true
}

cleanup
trap cleanup EXIT

docker run -d --name "${container}" "${image}" >/dev/null

ready=0
for _ in $(seq 1 90); do
    if docker logs "${container}" 2>&1 | grep -q "Integration databases are ready."; then
        ready=1
        break
    fi
    sleep 1
done

if [ "${ready}" -ne 1 ]; then
    docker logs "${container}"
    echo "Container did not become ready." >&2
    exit 1
fi

mysql_version="$(docker exec "${container}" mysql -N -B -uusr_test -ptest -e "SELECT VERSION();")"
postgres_version="$(docker exec "${container}" runuser -u postgres -- psql -tA -c "SHOW server_version;")"

docker exec "${container}" mysql -uusr_test -ptest -D sakila -e "SELECT COUNT(*) AS actor_count FROM actor;"
docker exec "${container}" mysql -uusr_test -ptest -D sakila -e "SELECT COUNT(*) AS nul_notes FROM customer WHERE LOCATE(CHAR(0), notes) > 0;"
docker exec "${container}" runuser -u postgres -- psql -d db_test -tA -c "SELECT current_user, current_database();"

docker exec "${container}" mysql -N -B -uusr_test -ptest -D sakila -e "SELECT COUNT(*) FROM actor;" | grep -qx "5"
docker exec "${container}" mysql -N -B -uusr_test -ptest -D sakila -e "SELECT COUNT(*) FROM customer WHERE LOCATE(CHAR(0), notes) > 0;" | grep -qx "1"
docker exec "${container}" runuser -u postgres -- psql -d db_test -tA -c "SELECT current_setting('server_version_num')::int >= 180000;" | grep -qx "t"

echo "MySQL ${mysql_version} and PostgreSQL ${postgres_version} smoke test passed."
