#!/bin/bash
#
# Entrypoint
#
# Ensure persistent data is stored in /data/ and then start the stack

set -euo pipefail

start() {
  echo "Starting CompreFace GPU" >&2
  values=$(cat /data/options.json)
  for s in $(echo "$values" | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
      export "${s?}"
  done

  if [ "$PGDATA" == "/data/database" ] && [ -d /data ]
  then
    if [ ! -d  /data/database ]
    then
      echo "Copying database to /data/database" >&2
      if [ -d /var/lib/postgresql/data ]
      then
        cp -rp /var/lib/postgresql/data /data/database
      else
        mkdir -p /data/database
        mkdir -p /var/lib/postgresql/data
        chown postgres:postgres /data/database
        su - postgres -c "initdb -D /data/database"
      fi
    fi
  fi

  chown -R postgres:postgres "$PGDATA"

  exec /usr/bin/supervisord
}



if grep -q avx /proc/cpuinfo
then
  start
else
  echo "AVX not detected" >&2
  exit 1
fi
