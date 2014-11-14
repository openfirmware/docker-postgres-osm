#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
  first_run=false
  chown -R postgres "$PGDATA"

  if [ -z "$(ls -A "$PGDATA")" ]; then
    # This is the first time the container has been started
    first_run=true
    gosu postgres initdb

    # Enable access for all hosts. This is okay for a docker container.
    { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf

    # Update the Postgres Configuration for OSM Stack
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
  fi

  if [[ "$first_run" = true ]]; then
    echo "Starting Postgres and creating OSM database"
    gosu postgres pg_ctl -w start
    gosu postgres createuser "$OSM_USER"
    gosu postgres createdb -E UTF8 -O "$OSM_USER" "$OSM_DB"
    gosu postgres psql "$OSM_DB" <<EOF
    CREATE EXTENSION postgis;
    CREATE EXTENSION hstore;
    ALTER TABLE geometry_columns OWNER TO "${OSM_USER}";
    ALTER TABLE spatial_ref_sys OWNER TO "${OSM_USER}";
EOF

    # Run the server in the foreground
    echo "Done init for OSM. One final restart."
    gosu postgres pg_ctl stop
  fi
  exec gosu postgres "$@"
fi

exec "$@"
