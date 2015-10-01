create or replace view vertex_fact_daily_gl_ledger_credit_change as

select lcc.effective_day_id, -- dimension reference
  lcc.credit_change_type_id,  -- dimension reference
  lcc.accounting_category_id, -- dimension reference
  COALESCE(dim_ma.contract_entity_id, 0) as contract_entity_id, -- dimension reference
  lcc.partner_id, -- dimension reference
  COALESCE(av.aggregate_version_id, 0) as aggregate_version_id,
  SUM(case when lcc.price > 0 then 1 else 0 end) as num_items_plus,
  SUM(case when lcc.price > 0 then lcc.price else 0 end) as total_amount_plus,
  SUM(case when lcc.price <= 0 then 1 else 0 end) as num_items_minus,
  SUM(case when lcc.price <= 0 then lcc.price else 0 end) as total_amount_minus
from vertex_materialized.vertex_fact_ledger_credit_change lcc
inner join vertex_materialized.vertex_dim_credit_change_type dim_cct on lcc.credit_change_type_id = dim_cct.credit_change_type_id
left join vertex_materialized.vertex_dim_managed_account dim_ma on lcc.fund_account_id = dim_ma.fund_account_id
inner join verse.verse_ods_kiva_gl_aggregate_version av on av.effective_day_id = lcc.effective_day_id and lcc.create_time between av.aggregation_start_time and av.aggregation_end_time
where av.verse_report_name = 'daily_gl_entries'
group by lcc.effective_day_id, lcc.credit_change_type_id, lcc.partner_id, lcc.accounting_category_id,
  dim_ma.contract_entity_id, av.aggregate_version_id
;