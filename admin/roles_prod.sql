-- *This needs to be run by a superuser*

-- grant administration of roles to certain users
--   push
create user push;
--alter user push identified by 'pwd'; --uncomment this with real pwd
--grant authentication host_pass to push; --uncomment with previous line
grant role_admin_role to push;
alter user push default role role_admin_role;

