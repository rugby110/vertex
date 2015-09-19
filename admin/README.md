# overview #
This admin directory contains the scripts used to setup roles, users, schemas, and grants on our vertica databases.
# dev initial setup by superuser #
`vsql <roles_all.sql`
`vsql <roles_dev.sql`
# prod initial setup by superuser #
`vsql <roles_all.sql`
`vsql <roles_prod.sql`
# dev sequence as run during deployments by devpush #
`vsql <setup_users_schemas_grants_all.sql`
`vsql <setup_users_schemas_grants_dev.sql`
# prod sequence as run during deployments by push #
`vsql <setup_users_schemas_grants_all.sql`
`vsql <setup_users_schemas_grants_prod.sql`
