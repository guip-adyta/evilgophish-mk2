#!/bin/bash
#
#mkdir -p /opt/db
#chown -R app-gophish:app-gophish /opt/db
DB_PATH="/opt/db/gophish.db"
if [ ! -f "$DB_PATH" ]; then
    echo "SQLite DB file does not exist. Initializing..."
    sqlite3 $DB_PATH "VACUUM;"
    echo "Created DB file"
else
    echo "SQLite DB file exists."
fi
exec "$@"