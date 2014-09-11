#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
  chown -R postgres "$PGDATA"
  
  if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb
    
    ./update-access.sh
    ./update-settings.sh
  fi
  
  exec gosu postgres "$@"
fi

exec "$@"
