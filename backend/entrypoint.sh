#!/bin/sh
set -euo pipefail
echo "[entrypoint] Applying database migrations"
python manage.py migrate --noinput || { echo "[entrypoint] Migration failed" >&2; exit 1; }
echo "[entrypoint] Migrations applied successfully"
exec "$@"