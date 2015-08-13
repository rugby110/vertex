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

-- grant verse schema access 
grant usage on schema verse to vertex, van, nikkiw, sam, looker, bamboo;
grant select on all tables in schema verse to van, nikkiw, sam, looker, bamboo;

-- this is a key requirement, the vertex user needs to be granted
--   select ... WITH GRANT OPTION for the tables in the verse in order to grant
--   usage to others for the views which pull from the verse tables
grant select on all tables in schema verse to vertex with grant option;

-- grant vertex schema access
grant usage on schema vertex to van, nikkiw, sam, looker;
grant select on all tables in schema vertex to van, nikkiw, sam, looker;

-- select rights need to be granted to each view as in the line below 
-- grant select on vertex.vertex_dim_credit_change_type to vertex_read_only_view_role;
--
-- this has been automated by the script bin/view_permission_updater.php

-- creation of the role will fail after it has been run once, but no harm is done
create role vertex_read_only_view_role; 
grant vertex_read_only_view_role to van, nikkiw, sam, looker;

alter user van default role vertex_read_only_view_role;
alter user nikkiw default role vertex_read_only_view_role;
alter user sam default role vertex_read_only_view_role;
alter user looker default role vertex_read_only_view_role;
