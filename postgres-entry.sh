#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
  chown -R postgres "$PGDATA"
  
  if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb
    
    ./update-access.sh
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    
  fi
  
  exec gosu postgres "$@"
fi

exec "$@"
