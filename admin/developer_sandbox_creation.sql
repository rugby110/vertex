create schema IF NOT EXISTS van AUTHORIZATION van;
grant all on schema van to van with grant option;

create schema IF NOT EXISTS nikkiw AUTHORIZATION nikkiw;
grant all on schema nikkiw to nikkiw with grant option;

create schema IF NOT EXISTS sam AUTHORIZATION sam;
grant all on schema sam to sam with grant option;

create schema IF NOT EXISTS looker AUTHORIZATION looker;
grant all on schema looker to looker with grant option;

-- grant verse schema access 
grant usage on schema verse to vertex, van, nikkiw, sam, looker;
grant select on all tables in schema verse to vertex, van, nikkiw, sam, looker;

-- grant vertex schema access
grant usage on schema vertex to van, nikkiw, sam, looker;
grant select on all tables in schema vertex to van, nikkiw, sam, looker;