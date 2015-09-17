-- vertex and ods_kiva schemas
create schema IF NOT EXISTS vertex AUTHORIZATION vertex;
create schema IF NOT EXISTS ods_kiva AUTHORIZATION vertex;
grant all on schema vertex to vertex with grant option;
grant all on schema ods_kiva to vertex with grant option;
grant all on schema vertex to devpush with grant option;
grant all on schema ods_kiva to devpush;

-- verse schemas
create schema IF NOT EXISTS verse AUTHORIZATION verse;
create schema IF NOT EXISTS verse_publish AUTHORIZATION verse;
create schema IF NOT EXISTS verse_live AUTHORIZATION verse;
grant all on schema verse to verse with grant option;
grant all on schema verse_publish to verse with grant option;
grant all on schema verse_live to verse with grant option;

grant create on database verticanow to verse; --for renaming schemas during verse publishing

-- permissions for the vertex and devpush user
GRANT EXECUTE ON TRANSFORM FUNCTION group_concat(Varchar) to vertex,devpush;
-- this is a key requirement, the vertex and devpush users need to be granted
--   select ... WITH GRANT OPTION for the tables in the verse in order to grant
--   usage to others for the views which pull from the verse tables
grant usage on schema verse to vertex, devpush;
grant select on all tables in schema verse to vertex, devpush with grant option;

-- the devpush user will use the vertex schema, but this is for
-- developing the deployment process
create schema IF NOT EXISTS devpush AUTHORIZATION devpush;
grant all on schema devpush to devpush with grant option;

