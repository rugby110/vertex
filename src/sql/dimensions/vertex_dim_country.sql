create or replace view vertex_dim_country as

select  id as country_id, 
        name, 
        irs_region
from verse.verse_ods_kiva_country