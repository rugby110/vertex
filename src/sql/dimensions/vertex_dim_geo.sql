/*

NOTE:  the verse had a row with id = 0 and name = 'None'.
If needed, we can probably do hard-coded insert with a UNION

NOTE:  there seems to have been some work around adding lat/long, but these cols were empty in the verse.  this can be updated if need be.

 */

create or replace view vertex_dim_geo as
select distinct
	t.id as geo_id,
	t.name as name,
	t.country_id as country_id,
	t.id as town_id,
	c.region as lender_region_id
from town t
	left join country c on t.country_id = c.id