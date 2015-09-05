create or replace view vertex_dim_country as

select  c.id as country_id, 
        c.name, 
        c.irs_region,
        vc.alpha3_code as country_code
from country c
left join vertex_country vc on vc.short_name = c.name;
