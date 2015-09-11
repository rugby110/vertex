/**
I'm leaving out the row sith id = 0 name = 'None'
 */
create or replace view vertex_dim_language as
select
	l.id as language_id, l.name, l.iso_code
from
	language l