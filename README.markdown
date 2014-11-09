# docker-postgres-osm

The base postgres image from Docker with extensions for importing OpenStreetMap data.

## Build Instructions

Can be built from the Dockerfile:

    # docker build -t openfirmware/postgres-osm github.com/openfirmware/docker-postgres-osm.git

## Running Postgres

Build the image:

    # docker build -t openfirmware/postgres-osm .

Then launch the container:

    # docker run -d --name postgres-osm openfirmware/postgres-osm

Then test with `postgresql-client`:

    # docker run -i -t --rm --link postgres-osm:pg --entrypoint /bin/bash postgres:9.3.5 -c 'psql -h $PG_PORT_5432_TCP_ADDR -p $PG_PORT_5432_TCP_PORT -U postgres postgres'

This will use Docker's container links to connect to Postgresql without having Postgresql exposed to the host or network.

## Customization

By default, the database created will be called `gis` and be owned by user `osm`. These can be changed with environment variables in the RUN command:

    # docker run -d --name postgres-osm -e "OSM_USER=www-data" -e "OSM_DB=osm_dataset" openfirmware/postgres-osm

These variables can be accessed from linked containers. Consider the link alias `pg`:

    PG_ENV_OSM_USER=osm
    PG_ENV_OSM_DB=gis

These can then be passed into import scripts or clients in other containers.

## Todo

This Dockerfile is UNFINISHED. There are still some remaining tasks before it is usable for an OpenStreetMap database.

* Add custom tweaks to PostgreSQL configuration for OSM

## About

This Dockerfile was built with information from the [Ubuntu 14.04 Switch2OSM guide](http://switch2osm.org/serving-tiles/manually-building-a-tile-server-14-04/).

## Related Docker Images

* [Postgres Image](https://registry.hub.docker.com/_/postgres/)
* [Postgres Image Repo](https://github.com/docker-library/postgres)

