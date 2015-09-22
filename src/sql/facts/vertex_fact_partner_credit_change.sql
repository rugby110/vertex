create or replace view vertex_fact_partner_credit_change as

select pcc.id as partner_credit_change_id,
  dim_p.partner_id,
  cast(pcc.price as numeric(36,2)) as price, --this is a currency amount, so making it only 2 decimal places.
  COALESCE(pcc.ref_id, 0) as ref_id,
  COALESCE(pcc.admin_user_id, 0) as admin_user_id,
  pcc.create_time,
	TO_CHAR(TO_TIMESTAMP(pcc.create_time), 'YYYYMMDD')::INT as create_day_id,
  pcc.effective_time,
	TO_CHAR(TO_TIMESTAMP(pcc.effective_time), 'YYYYMMDD')::INT as effective_day_id,
	COALESCE(pcc.statement_id, 0) as statement_id,
  dim_cct.credit_change_type_id
from verse.verse_ods_kiva_partner_credit_change pcc
inner join vertex_dim_credit_change_type dim_cct on dim_cct.credit_change_type_id = pcc.type_id and dim_cct.source_table_name = 'partner_credit_change'
inner join vertex_dim_partner dim_p on dim_p.partner_id = pcc.partner_id
