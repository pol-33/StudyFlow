#!/bin/sh
set -euo pipefail

echo "[entrypoint] Validating environment"
DEBUG_VAL=${DEBUG:-True}
SECRET=${SECRET_KEY:-}
if [ "$DEBUG_VAL" != "True" ] && [ -z "$SECRET" ]; then
  echo "[entrypoint] ERROR: SECRET_KEY is required when DEBUG=False" >&2
  exit 1
fi
if [ -z "${ALLOWED_HOSTS:-}" ]; then
  echo "[entrypoint] WARN: ALLOWED_HOSTS is not set; using defaults" >&2
fi
if [ -z "${CORS_ALLOWED_ORIGINS:-}" ]; then
  echo "[entrypoint] WARN: CORS_ALLOWED_ORIGINS is not set; using defaults" >&2
fi

#python manage.py makemigrations || python manage.py makemigrations --merge --noinput

echo "[entrypoint] Applying database migrations"
python manage.py migrate --noinput || { echo "[entrypoint] Migration failed" >&2; exit 1; }
echo "[entrypoint] Migrations applied successfully"
exec "$@"
