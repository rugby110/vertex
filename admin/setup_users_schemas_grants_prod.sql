-- This script can be run by push or the superuser on prod. 
set role role_admin_role;

-- tungsten
create user tungsten;
--alter user tungsten identified by 'pwd'; --uncomment with real pwd
--grant authentication host_pass to tungsten; --uncomment with previous line
grant verticanow_admin_role to tungsten;
alter user tungsten default role verticanow_admin_role;

