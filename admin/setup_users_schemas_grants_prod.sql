-- This script to be run by the superuser on prod. 

-- push
--create user push identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to push;
grant role_admin_role to push;
alter user push default role role_admin_role;
alter user push search_path vertex, ods_kiva, verse, public;

-- tungsten
--create user tungsten identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to tungsten;
grant verticanow_admin_role to tungsten;
alter user tungsten default role verticanow_admin_role;

-- looker
--create user looker identified by 'pwd'; -- uncomment, change pwd, and run this manually
grant authentication host_pass to looker;
grant vertex_read_only_view_role to looker;
alter user looker default role vertex_read_only_view_role;
create schema IF NOT EXISTS looker AUTHORIZATION looker;
alter user looker search_path "$user", vertex, ods_kiva, verse, public;

