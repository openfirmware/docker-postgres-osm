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

  echo "Starting Postgres and creating OSM database"
  gosu postgres pg_ctl -w start
  gosu postgres createuser osm
  gosu postgres createdb -E UTF8 -O osm gis
  gosu postgres psql gis <<EOF
  CREATE EXTENSION postgis;
  ALTER TABLE geometry_columns OWNER TO osm;
  ALTER TABLE spatial_ref_sys OWNER TO osm;
EOF

  # Run the server in the foreground
  echo "Done init for OSM. One final restart."
  gosu postgres pg_ctl stop
  exec gosu postgres "$@"
fi

exec "$@"
