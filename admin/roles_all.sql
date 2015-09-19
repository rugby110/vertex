-- *This needs to be run by a superuser*

-- create roles
create role role_admin_role;
--    verticanow_admin_role
create role verticanow_admin_role;
grant verticanow_admin_role to role_admin_role with grant option;
--    vertex_read_only_view_role
create role vertex_read_only_view_role;
grant vertex_read_only_view_role to role_admin_role with grant option;

-- initial role permissions
-- the following permission allows users to rename schemas (verse publish needs this)
grant create on database verticanow to verticanow_admin_role with grant option;

