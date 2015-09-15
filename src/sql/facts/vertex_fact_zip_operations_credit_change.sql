create or replace view vertex_fact_zip_operations_credit_change as

select occ.id as zip_operations_credit_change_id,
  occ.effective_time,
	TO_CHAR(TO_TIMESTAMP(occ.effective_time), 'YYYYMMDD')::INT as effective_day_id,
	occ.create_time,
	TO_CHAR(TO_TIMESTAMP(occ.create_time), 'YYYYMMDD')::INT as create_day_id,
	occ.price,
	occ.currency,
	occ.description,
	occ.pp_txn_id,
	occ.mpesa_receipt_no,
	occ.admin_user_id,
	dim_cct.credit_change_type_id,
  occ.fx_rate_id
from verse.verse_ods_zip_operations_credit_change occ
inner join vertex_dim_credit_change_type dim_cct on dim_cct.type_name = occ.type and dim_cct.source_table_name = 'zip.operations_credit_change'
;

