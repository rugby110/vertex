/**
I'm not appending the empty region id from the verse with id = 0
 */
create or replace view vertex_dim_lender_region as

select distinct region as lender_region_id
from country
where region != ''