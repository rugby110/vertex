-- This script can be run by devpush on dev, push on prod, 
-- or the superuser on either
set role role_admin_role;

-- vertex user and related schema
create user vertex;
--alter user vertex identified by 'lpass:vertex_user_vertex:password';
--grant authentication host_pass to vertex; --uncomment with previous line
grant vertex_read_only_view_role to vertex;
alter user vertex default role vertex_read_only_view_role;
create schema IF NOT EXISTS vertex AUTHORIZATION vertex;
create schema IF NOT EXISTS ods_kiva AUTHORIZATION vertex;

-- verse user and related schema
create user verse;
--alter user verse identified by 'lpass:vertex_user_verse:password';
--grant authentication host_pass to verse; --uncomment with previous line
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
