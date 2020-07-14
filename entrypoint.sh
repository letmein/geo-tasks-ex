#!/bin/bash

while ! pg_isready -q -h $DATABASE_HOST -p 5432 -U $DATABASE_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

bin="/app/bin/app"
eval "$bin eval \"Db.Release.migrate\""
exec "$bin" "start"
