#!/bin/bash
set -e

gosu postgres postgres --single -jE <<-EOL
  CREATE USER "$OSM_USER";
EOL

gosu postgres postgres --single -jE <<-EOL
  CREATE DATABASE "$OSM_DB";
EOL

gosu postgres postgres --single -jE <<-EOL
  GRANT ALL ON DATABASE "$OSM_DB" TO "$OSM_USER";
EOL

# In case a tablespace and specific mountpoint was provided, execute tablespace creation and assign db to tablespace
if env | grep -q ^DB_STORAGE_NAME
  then
    gosu postgres postgres --single -jE <<-EOL
      CREATE TABLESPACE $DB_STORAGE_NAME LOCATION '$DB_STORAGE_MOUNTPOINT';
    EOL
    gosu postgres postgres --single -jE <<-EOL
      ALTER DATABASE $OSM_DB SET TABLESPACE $DB_STORAGE_NAME;
    EOL
fi

# Postgis extension cannot be created in single user mode.
# So we will do it the kludge way by starting the server,
# updating the DB, then shutting down the server so the
# rest of the docker-postgres init scripts can finish.

gosu postgres pg_ctl -w start
gosu postgres psql "$OSM_DB" <<-EOL
  CREATE EXTENSION postgis;
  CREATE EXTENSION hstore;
  ALTER TABLE geometry_columns OWNER TO "$OSM_USER";
  ALTER TABLE spatial_ref_sys OWNER TO "$OSM_USER";
EOL
    
gosu postgres pg_ctl stop

