#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
  chown -R postgres "$PGDATA"

  if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb

    # Enable access for all hosts. This is okay for a docker container.
    { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf

    # Update the Postgres Configuration for OSM Stack
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
  fi

  exec gosu postgres "$@"
fi

exec "$@"
