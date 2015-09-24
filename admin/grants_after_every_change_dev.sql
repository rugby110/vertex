-- This needs to be run after every change to a view.
-- everything in the user search_path needs to be here except '$user'
grant select on all tables in schema vertex to vertex_read_only_view_role;
grant select on all tables in schema ods_kiva to vertex_read_only_view_role;
grant select on all tables in schema verse to vertex_read_only_view_role;
grant all on all tables in schema vertex to devpush with grant option;
grant all on all tables in schema ods_kiva to devpush with grant option;
grant all on all tables in schema verse to devpush with grant option;
