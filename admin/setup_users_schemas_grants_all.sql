-- This script is to be run by the superuser on dev and prod
-- create roles
create role role_admin_role;
--    verticanow_admin_role
create role verticanow_admin_role;
grant verticanow_admin_role to role_admin_role with admin option;
--    vertex_read_only_view_role
create role vertex_read_only_view_role;
grant vertex_read_only_view_role to role_admin_role with admin option;

-- initial role permissions
-- the following permission allows users to rename schemas (verse publish needs this)
grant create on database verticanow to verticanow_admin_role with grant option;

-- vertex user and related schema
--create user vertex identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to vertex;
grant vertex_read_only_view_role to vertex;
alter user vertex default role vertex_read_only_view_role;
create schema IF NOT EXISTS vertex AUTHORIZATION vertex;
create schema IF NOT EXISTS ods_kiva AUTHORIZATION vertex;

-- verse user and related schema
--create user verse identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to verse;
grant verticanow_admin_role to verse; --for renaming schemas during verse publishing
alter user verse default role verticanow_admin_role;
create schema IF NOT EXISTS verse AUTHORIZATION verse;
create schema IF NOT EXISTS verse_publish AUTHORIZATION verse;
create schema IF NOT EXISTS verse_live AUTHORIZATION verse;

-- grants for the vertex_read_only_view_role
grant usage on schema ods_kiva to vertex_read_only_view_role;
grant select on all tables in schema ods_kiva to vertex_read_only_view_role;
grant usage on schema vertex to vertex_read_only_view_role;
grant select on all tables in schema vertex to vertex_read_only_view_role;
grant usage on schema verse to vertex_read_only_view_role;
grant select on all tables in schema verse to vertex_read_only_view_role;
GRANT EXECUTE ON TRANSFORM FUNCTION group_concat(Varchar) to vertex_read_only_view_role;
