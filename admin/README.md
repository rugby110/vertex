# overview #
This admin directory contains the scripts used to setup roles, users, schemas, and grants on our vertica databases.
# dev sequence to be run by superuser #
```bash
vsql <setup_users_schemas_grants_all.sql
vsql <setup_users_schemas_grants_dev.sql
```
# prod sequence to be run by superuser #
```bash
vsql <setup_users_schemas_grants_all.sql
vsql <setup_users_schemas_grants_prod.sql
```
