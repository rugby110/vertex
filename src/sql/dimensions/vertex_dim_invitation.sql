create or replace view vertex_dim_invitation as

select id as invitation_id, 
       COALESCE(team_id, 0) as team_id,
       TO_CHAR(TO_TIMESTAMP(date_sent), 'YYYYMMDD')::INT as date_sent_day_id,
       created_as_type, 
       source,
       -- reversed date order for vertex syntax: ( datepart , starttime , endtime )
       datediff(dd,to_timestamp(date_sent),to_timestamp(date_confirmed)) as days_to_confirm
from invitation;