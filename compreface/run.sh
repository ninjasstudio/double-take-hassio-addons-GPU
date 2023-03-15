#!/bin/bash
#
# Entrypoint
#
# Ensure persistent data is stored in /data/ and then start the stack


start() {
  echo "Starting CompreFace GPU"
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
        echo "Initializing database" >&2
      fi
    fi
  fi

   # change permissions in case they were corrupted
    chown -R postgres:postgres $PGDATA
    chmod 700 $PGDATA

    echo Starting compreface-postgres-db
    supervisorctl start compreface-postgres-db
}



if grep -q avx /proc/cpuinfo
then
  start
else
  echo "AVX not detected" >&2
  exit 1
fi
