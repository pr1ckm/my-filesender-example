#!/bin/bash
set -e

echo "Warte auf Datenbankverbindung (PostgreSQL)..."
until pg_isready -h db -U filesender -d filesender; do
  sleep 1
done

echo "Datenbank ist erreichbar."

# Rechte für Upload- und Logverzeichnis setzen
chown -R www-data:www-data /opt/filesender/files /opt/filesender/log

# Automatische Schema-Initialisierung / Migration für FileSender v3.0
echo "Führe FileSender Datenbank-Upgrade/Initialisierung aus..."
php /opt/filesender/scripts/upgrade/database.php

echo "FileSender v3.0 wurde erfolgreich gestartet."
exec "$@"