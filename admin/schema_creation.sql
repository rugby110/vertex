create schema IF NOT EXISTS vertex AUTHORIZATION vertex;
create schema IF NOT EXISTS ods_kiva AUTHORIZATION vertex;
grant all on schema vertex to vertex with grant option;
grant all on schema ods_kiva to vertex with grant option;

create schema IF NOT EXISTS verse AUTHORIZATION verse;
create schema IF NOT EXISTS verse_publish AUTHORIZATION verse;
create schema IF NOT EXISTS verse_live AUTHORIZATION verse;
grant all on schema verse to verse with grant option;
grant all on schema verse_publish to verse with grant option;
grant all on schema verse_live to verse with grant option;

grant create on database verticanow to verse; --for renaming schemas during verse publishing
