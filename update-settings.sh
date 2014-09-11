# Update the Postgres Configuration for OSM Stack
#!/bin/bash
set -e

sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
