-- This script to be run by the superuser on dev

--   devpush
--create user devpush identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to devpush;
grant role_admin_role to devpush;
alter user devpush default role role_admin_role;
alter user devpush search_path vertex, ods_kiva, verse, public;
grant all on all tables in schema vertex to devpush with grant option;
grant all on all tables in schema ods_kiva to devpush with grant option;
grant all on all tables in schema verse to devpush with grant option;

-- tungsten_dev
--create user tungsten_dev identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to tungsten_dev;
grant verticanow_admin_role to tungsten_dev;
alter user tungsten_dev default role verticanow_admin_role;

-- looker
--create user looker identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to looker;
grant vertex_read_only_view_role to looker;
alter user looker default role vertex_read_only_view_role;
create schema IF NOT EXISTS looker AUTHORIZATION looker;
alter user looker search_path "$user", vertex, ods_kiva, verse, public;

-- van
--create user van identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to van;
grant vertex_read_only_view_role to van;
alter user van default role vertex_read_only_view_role;
create schema IF NOT EXISTS van AUTHORIZATION van;
alter user van search_path "$user", ods_kiva, verse, public;

-- nikkiw
--create user nikkiw identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to nikkiw;
grant vertex_read_only_view_role to nikkiw;
alter user nikkiw default role vertex_read_only_view_role;
create schema IF NOT EXISTS nikkiw AUTHORIZATION nikkiw;
alter user nikkiw search_path "$user", ods_kiva, verse, public;

-- dthomas
--create user dthomas identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to dthomas;
grant vertex_read_only_view_role to dthomas;
alter user dthomas default role vertex_read_only_view_role;
create schema IF NOT EXISTS dthomas AUTHORIZATION dthomas;
alter user dthomas search_path "$user", ods_kiva, verse, public;

-- jake
--create user jake identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to jake;
grant vertex_read_only_view_role to jake;
alter user jake default role vertex_read_only_view_role;
create schema IF NOT EXISTS jake AUTHORIZATION jake;
alter user jake search_path "$user", ods_kiva, verse, public;

-- zahid
--create user zahid identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to zahid;
grant vertex_read_only_view_role to zahid;
alter user zahid default role vertex_read_only_view_role;
create schema IF NOT EXISTS zahid AUTHORIZATION zahid;
alter user zahid search_path "$user", ods_kiva, verse, public;

-- amy
--create user amy identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to amy;
grant vertex_read_only_view_role to amy;
alter user amy default role vertex_read_only_view_role;
create schema IF NOT EXISTS amy AUTHORIZATION amy;
alter user amy search_path "$user", ods_kiva, verse, public;

-- mike
--create user mike identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to mike;
grant vertex_read_only_view_role to mike;
alter user mike default role vertex_read_only_view_role;
create schema IF NOT EXISTS mike AUTHORIZATION mike;
alter user mike search_path "$user", ods_kiva, verse, public;

-- bamboo
--create user bamboo identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to bamboo;
grant vertex_read_only_view_role to bamboo;
alter user bamboo default role vertex_read_only_view_role;
create schema IF NOT EXISTS bamboo AUTHORIZATION bamboo;
alter user bamboo search_path "$user", ods_kiva, verse, public;

