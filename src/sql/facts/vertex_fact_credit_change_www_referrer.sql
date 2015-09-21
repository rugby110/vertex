--VERTEX_NO_DEPLOY
create or replace view vertex_fact_credit_change_www_referrer as

select cc.credit_change_id, dim.referrer_id
from vertex_fact_credit_change_core cc
inner join verse_ods_www_event e on e.item_id=cc.credit_change_id
inner join verse_ods_www_document doc on (e.document_id=doc.v_id AND doc.category='credit_change')
inner join verse_ods_www_trackingsession ts on ts.v_id=e.trackingsession_id
inner join verse_ods_www_referrer_clean ref on ref.v_id=ts.referrer_id
inner join vertex_dim_www_referrer dim on 
	ref.source=dim.source AND 
	ref.medium=dim.medium AND 
	ref.campaign=dim.campaign AND 
	ref.campaign_content=dim.campaign_content
