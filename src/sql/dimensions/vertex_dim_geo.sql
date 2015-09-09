/**
NOTE:  the verse had a row with id = 0 and name = 'None'.
If needed, we can probably do hard-coded insert with a UNION
 */
create or replace view vertex_dim_geo as
select distinct
	t.id as geo_id,
	t.name as name,
	t.country_id as country_id,
	t.id as town_id,
	c.irs_region as lender_region_id
from town t
	left join vertex_dim_country c on t.country_id = c.country_id