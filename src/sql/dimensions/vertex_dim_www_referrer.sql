create or replace view vertex_dim_www_referrer as
select
        distinct MD5(
                        COALESCE(source,'') || 
                        COALESCE(medium,'') ||
                        COALESCE(campaign,'') || 
                        case when source='jg' then ''
                                else COALESCE(campaign_content,'')
                        end
                 ) as referrer_id,
        COALESCE(source,'') as source,
        COALESCE(medium,'') as medium,
        COALESCE(campaign,'') as campaign,
        case when source='jg' then ''
             else COALESCE(campaign_content,'')
        end as campaign_content
from verse.verse_ods_www_referrer
