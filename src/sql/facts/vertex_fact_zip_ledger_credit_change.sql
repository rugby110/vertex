create or replace view vertex_fact_zip_ledger_credit_change as

select lcc.id as zip_ledger_credit_change_id,
  dim_cct.credit_change_type_id,
  CASE
      WHEN lcc.fund_account_id IS NULL THEN 0
			WHEN fa.contract_entity_id IS NULL THEN (select id from vertex_dim_accounting_category where accounting_category = 'self_directed')
			WHEN fa.contract_entity_id = 1 THEN (select id from vertex_dim_accounting_category where accounting_category = 'kmf')
			ELSE (select id from vertex_dim_accounting_category where accounting_category = 'managed_account')
	END as accounting_category_id,
  COALESCE(lcc.fund_account_id, 0) as fund_account_id,
  lcc.partner_id,
  lcc.price,
  'USD' as currency,
  lcc.effective_time,
	TO_CHAR(TO_TIMESTAMP(lcc.effective_time), 'YYYYMMDD')::INT as effective_day_id,
	lcc.ref_id,
	lcc.create_time,
	TO_CHAR(TO_TIMESTAMP(lcc.create_time), 'YYYYMMDD')::INT as create_day_id,
  lcc.creator_id,
  NULL as fx_rate_id
from verse.verse_ods_zip_ledger_credit_change lcc
left join verse.verse_ods_zip_fund_accounts fa ON fa.id = lcc.fund_account_id
left join vertex_dim_credit_change_type dim_cct ON dim_cct.type_name = lcc.type AND dim_cct.source_table_name = 'zip.ledger_credit_change'
;
