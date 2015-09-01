create or replace view vertex_dim_credit_change_type as
select	
        cct.id as credit_change_type_id,
	type_name,
	requires_tran='yes' as requires_tran,
	item_refers_to,
	ref_refers_to,
	inactive_date as inactive_time,
	requires_note='yes' as requires_note,
	description_format,
	create_time,
	category,
	table_name as source_table_name,
	type_name as credit_change_type_label,
	enforce_closed_period,
	sign,
	gl_name,
	initiated_by,
	NULL as fx_rate_from,
	case when (ref_refers_to = 'credit_change' or gl_name in ('cc_loan_share_recapture', 'cc_gift_cancellation')) then true
	     else false
	end as is_modification,
	case when gl_name = 'cc_lender_check_sent' or gl_name = 'cc_zip_credit_transfer' then '<none>'
	     else 
	     ccg.name
	end as reporting_group
from verse.verse_ods_kiva_credit_change_type cct
left join vertex_credit_change_group_map ccgm on cct.id = ccgm.credit_change_type_id
left join vertex_credit_change_group ccg on ccgm.credit_change_group_id = ccg.id

UNION DISTINCT

select
	id,
	type_name,
	requires_tran='yes' as requires_tran,
	item_refers_to,
	ref_refers_to,
	inactive_date as inactive_time,
	requires_note='yes' as requires_note,
	description_format,
	create_time,
	category,
	table_name as source_table_name,
	type_name as credit_change_type_label,
	enforce_closed_period,
	sign,
	gl_name,
	NULL as initiated_by,
	fx_rate_from,
	case when (ref_refers_to = 'credit_change' or gl_name in ('cc_loan_share_recapture', 'cc_gift_cancellation')) then true
	     else false
	end as is_modification,
	'<none>' as reporting_group
	
from verse.verse_ods_zip_credit_change_type;


