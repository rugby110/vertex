-- This script can be run by devpush or the superuser on dev
set role role_admin_role;

-- tungsten_dev
create user tungsten_dev;
--alter user tungsten_dev identified by 'lpass:vertex_user_tungsten_dev:password';
--grant authentication host_pass to tungsten_dev;
grant verticanow_admin_role to tungsten_dev;
alter user tungsten_dev default role verticanow_admin_role;

-- van
create user van;
--alter user van identified by 'lpass:vertex_user_van:password';
--grant authentication host_pass to van;
grant vertex_read_only_view_role to van;
alter user van default role vertex_read_only_view_role;
create schema IF NOT EXISTS van AUTHORIZATION van;
alter user van search_path "$user", ods_kiva, verse, public;

-- nikkiw
create user nikkiw;
--alter user nikkiw identified by 'lpass:vertex_user_nikkiw:password';
--grant authentication host_pass to nikkiw;
grant vertex_read_only_view_role to nikkiw;
alter user nikkiw default role vertex_read_only_view_role;
create schema IF NOT EXISTS nikkiw AUTHORIZATION nikkiw;
alter user nikkiw search_path "$user", ods_kiva, verse, public;

-- dthomas
create user dthomas;
--alter user dthomas identified by 'lpass:vertex_user_dthomas:password';
--grant authentication host_pass to dthomas;
grant vertex_read_only_view_role to dthomas;
alter user dthomas default role vertex_read_only_view_role;
create schema IF NOT EXISTS dthomas AUTHORIZATION dthomas;
alter user dthomas search_path "$user", ods_kiva, verse, public;

-- jake
create user jake;
--alter user jake identified by 'lpass:vertex_user_jake:password';
--grant authentication host_pass to jake;
grant vertex_read_only_view_role to jake;
alter user jake default role vertex_read_only_view_role;
create schema IF NOT EXISTS jake AUTHORIZATION jake;
alter user jake search_path "$user", ods_kiva, verse, public;

-- zahid
create user zahid;
--alter user zahid identified by 'lpass:vertex_user_zahid:password';
--grant authentication host_pass to zahid;
grant vertex_read_only_view_role to zahid;
alter user zahid default role vertex_read_only_view_role;
create schema IF NOT EXISTS zahid AUTHORIZATION zahid;
alter user zahid search_path "$user", ods_kiva, verse, public;

-- amy
create user amy;
--alter user amy identified by 'lpass:vertex_user_amy:password';
--grant authentication host_pass to amy;
grant vertex_read_only_view_role to amy;
alter user amy default role vertex_read_only_view_role;
create schema IF NOT EXISTS amy AUTHORIZATION amy;
alter user amy search_path "$user", ods_kiva, verse, public;

-- mike
create user mike;
--alter user mike identified by 'lpass:vertex_user_mike:password';
--grant authentication host_pass to mike;
grant vertex_read_only_view_role to mike;
alter user mike default role vertex_read_only_view_role;
create schema IF NOT EXISTS mike AUTHORIZATION mike;
alter user mike search_path "$user", ods_kiva, verse, public;

-- bamboo
create user bamboo;
--alter user bamboo identified by 'lpass:vertex_user_bamboo:password';
--grant authentication host_pass to bamboo;
grant vertex_read_only_view_role to bamboo;
alter user bamboo default role vertex_read_only_view_role;
create schema IF NOT EXISTS bamboo AUTHORIZATION bamboo;
alter user bamboo search_path "$user", ods_kiva, verse, public;

-- looker
create user looker;
--alter user looker identified by 'lpass:vertex_user_looker:password';
--grant authentication host_pass to looker;
grant vertex_read_only_view_role to looker;
alter user looker default role vertex_read_only_view_role;
create schema IF NOT EXISTS looker AUTHORIZATION looker;
alter user looker search_path "$user", ods_kiva, verse, public;

-- testuser
create user testuser;
--alter user testuser identified by 'lpass:vertex_user_testuser:password';
--grant authentication host_pass to testuser;
grant vertex_read_only_view_role to testuser;
alter user testuser default role vertex_read_only_view_role;
create schema IF NOT EXISTS testuser AUTHORIZATION testuser;
alter user testuser search_path "$user", ods_kiva, verse, public;

