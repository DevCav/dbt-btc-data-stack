#!/bin/bash

# Ensure required environment variables are set
if [ -z "$POSTGRES_USER" ]; then
  echo "Error: POSTGRES_USER is not set."
  exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo "Error: POSTGRES_PASSWORD is not set."
  exit 1
fi

# Wait for the database to be ready
while ! pg_isready -h superset_db -p 5432 -U ${POSTGRES_USER}; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 5
done

# Initialize the database
superset db upgrade

# Create an admin user
superset fab create-admin --username ${SUPERSET_ADMIN} --password ${SUPERSET_PASSWORD} --firstname Admin --lastname User --email admin@example.com

# Set the database URI connection
DB_CONNECTION_URI="postgresql://postgres:postgres@company_dw:5423/company_dw"
superset set-database-uri -d company_dw -u "${DB_CONNECTION_URI}"

# Initialize Superset
superset init

# Start the Superset server
exec gunicorn --bind "0.0.0.0:8088" --access-logfile '-' --error-logfile '-' --workers 1 --worker-class gthread --threads 20 --timeout 60 --limit-request-line 0 --limit-request-field_size 0 "superset.app:create_app()"