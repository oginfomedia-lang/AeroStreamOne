#!/bin/sh
# Runs once, the first time the postgres volume is created.
set -e
for db in auth_db inventory_db qa_db notification_db production_db procurement_db \
          reporting_db production_resource_db sales_db finance_db workorder_db; do
  psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE DATABASE $db"
done
