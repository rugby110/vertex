create schema IF NOT EXISTS van AUTHORIZATION van;
grant all on schema van to van with grant option;

create schema IF NOT EXISTS nikkiw AUTHORIZATION nikkiw;
grant all on schema nikkiw to nikkiw with grant option;

create schema IF NOT EXISTS sam AUTHORIZATION sam;
grant all on schema sam to sam with grant option;

create schema IF NOT EXISTS looker AUTHORIZATION looker;
grant all on schema looker to looker with grant option;

create schema IF NOT EXISTS bamboo AUTHORIZATION bamboo;
grant all on schema bamboo to bamboo with grant option;

create schema IF NOT EXISTS dthomas AUTHORIZATION dthomas;
grant all on schema dthomas to dthomas with grant option;

create schema IF NOT EXISTS jake AUTHORIZATION jake;
grant all on schema jake to jake with grant option;

create schema IF NOT EXISTS zahid AUTHORIZATION zahid;
grant all on schema zahid to zahid with grant option;

create schema IF NOT EXISTS amy AUTHORIZATION amy;
grant all on schema amy to amy with grant option;

-- grant verse schema access 
grant usage on schema verse to van, nikkiw, sam, looker, bamboo, dthomas, jake, zahid, amy;
grant select on all tables in schema verse to van, nikkiw, sam, looker, bamboo, dthomas, jake, zahid, amy;

-- grant vertex schema access
grant usage on schema vertex to van, nikkiw, sam, looker, bamboo, dthomas, jake, zahid, amy;
grant select on all tables in schema vertex to van, nikkiw, sam, looker, bamboo, dthomas, jake, zahid, amy;

-- select rights need to be granted to each view as in the line below 
-- grant select on vertex.vertex_dim_credit_change_type to vertex_read_only_view_role;
--
-- this has been automated by the script bin/view_permission_updater.php

-- creation of the role will fail after it has been run once, but no harm is done
create role vertex_read_only_view_role; 
grant vertex_read_only_view_role to van, nikkiw, sam, looker, bamboo, dthomas, jake, zahid, amy;

-- grant vertex schema access
grant usage on schema ods_kiva to vertex_read_only_view_role;
grant select on all tables in schema ods_kiva to vertex_read_only_view_role;

alter user van default role vertex_read_only_view_role;
alter user nikkiw default role vertex_read_only_view_role;
alter user sam default role vertex_read_only_view_role;
alter user looker default role vertex_read_only_view_role;
alter user bamboo default role vertex_read_only_view_role;
alter user dthomas default role vertex_read_only_view_role;
alter user jake default role vertex_read_only_view_role;
alter user zahid default role vertex_read_only_view_role;
alter user amy default role vertex_read_only_view_role;

GRANT EXECUTE ON TRANSFORM FUNCTION group_concat(Varchar) to vertex_read_only_view_role;
