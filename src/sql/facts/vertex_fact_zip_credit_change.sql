create or replace view vertex_fact_zip_credit_change as

select cc.id as zip_credit_change_id,
  COALESCE(cc.trans_id,0) as trans_id,  -- workaround to not have null values in here
  cc.fund_account_id,
  cast(cc.price as numeric(36,2)) as price, --this is a currency amount, so making it only 2 decimal places.
  dim_cct.credit_change_type_id,
  cc.create_time,
	TO_CHAR(TO_TIMESTAMP(cc.create_time), 'YYYYMMDD')::INT as create_day_id,
  cc.effective_time,
	TO_CHAR(TO_TIMESTAMP(cc.effective_time), 'YYYYMMDD')::INT as effective_day_id,
  cc.item_id,
  cc.ref_id,
  cc.changer_id,
  case
	  when cc.changer_id = 0 then 'system'
		when cc.changer_id = cc.fund_account_id then 'user'
		else 'admin'
	end as changer_type,
  cast(cc.new_balance as numeric(36,2)) as new_balance, ----this is a currency amount, so making it only 2 decimal places.
  cc.currency,
  case
	  when fa.contract_entity_id IS NULL then (select id from vertex_dim_accounting_category where accounting_category = 'self_directed')
	  when fa.contract_entity_id = 1 then (select id from vertex_dim_accounting_category where accounting_category = 'kmf')
		else (select id from vertex_dim_accounting_category where accounting_category = 'managed_account')
	end as accounting_category_id,
  NULL as fx_rate_id
from verse.verse_ods_zip_credit_change cc
inner join verse.verse_ods_zip_fund_accounts fa on fa.id = cc.fund_account_id
inner join vertex_dim_credit_change_type dim_cct on dim_cct.credit_change_type_id = cc.type_id and dim_cct.source_table_name = 'zip.credit_change' and dim_cct.type_name NOT like '%zip_%borrower%'
;

