/*
creates vertex_dim_activity.
I'm not appending the activity=0, name = 'None' row.
 */

create or replace view vertex_dim_activity as
select
	a.id as activity_id, a.name, am.sector_id
from
	activity a
	left join activity_mapper am on am.activity_id = a.id