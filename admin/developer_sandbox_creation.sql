create schema IF NOT EXISTS van_sandbox AUTHORIZATION van;
grant all on schema van_sandbox to van with grant option;

create schema IF NOT EXISTS nikkiw_sandbox AUTHORIZATION nikkiw;
grant all on schema nikkiw_sandbox to nikkiw with grant option;

-- verse_qa is a temporary standin for ods_kiva which is where raw kiva db tables live
grant usage on schema verse_qa to van, nikkiw;
grant select on all tables in schema verse_qa to van, nikkiw;
