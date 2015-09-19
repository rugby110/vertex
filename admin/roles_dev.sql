-- *This needs to be run by a superuser*

-- grant administration of roles to certain users
--   devpush
create user devpush;
--alter user devpush identified by 'pwd'; --uncomment this with real pwd
--grant authentication host_pass to devpush; --uncomment with the previous line
grant role_admin_role to devpush;
alter user devpush default role role_admin_role;

