create or replace view vertex_fact_zip_operations_credit_change as

select occ.id as zip_operations_credit_change_id,
	occ.effective_time,
	TO_CHAR(TO_TIMESTAMP(occ.effective_time), 'YYYYMMDD')::INT as effective_day_id,
	occ.create_time,
	TO_CHAR(TO_TIMESTAMP(occ.create_time), 'YYYYMMDD')::INT as create_day_id,
	cast(occ.price as numeric(36,2)) as price,
	occ.currency,
	COALESCE(occ.description,'') as description,
	COALESCE(occ.pp_txn_id,'') as pp_txn_id,
	COALESCE(occ.mpesa_receipt_no,'') as mpesa_receipt_no,
	COALESCE(occ.admin_user_id, 0) as admin_user_id,
	dim_cct.credit_change_type_id,
	occ.fx_rate_id
from verse.verse_ods_zip_operations_credit_change occ
left join vertex_dim_credit_change_type dim_cct on dim_cct.type_name = occ.type and dim_cct.source_table_name = 'zip.operations_credit_change'
;

