-- This script to be run by the superuser on prod. 

--   push
create user push;
--alter user push identified by 'pwd'; --uncomment this with real pwd
--grant authentication host_pass to push; --uncomment with previous line
grant role_admin_role to push;
alter user push default role role_admin_role;

-- tungsten
create user tungsten;
--alter user tungsten identified by 'pwd'; --uncomment with real pwd
--grant authentication host_pass to tungsten; --uncomment with previous line
grant verticanow_admin_role to tungsten;
alter user tungsten default role verticanow_admin_role;

