create or replace view vertex_dim_partner as

select  p.id as partner_id,
	p.name,
	p.growth_stage as risk_rating,
	p.status,
	TO_CHAR(TO_TIMESTAMP(p.first_fundraising_time), 'YYYYMMDD')::INT as first_fundraising_day_id,
	p.regional_director_email,
	p.operations_mgr_email as fss_email,
	p.relation_mgr_email as portfolio_mgr_email,
	case when p.charges_fees_interest='Yes' then true else false end as charges_fees_interest,
	case when p.enable_relisting='Yes' then true else false end as enable_relisting,
	p.activation_mode,
	p.due_diligence_type,
	p.institution_type,
	p.sector,
	p.credit_tier
	

from verse.verse_ods_kiva_partner p

/*  historical data for slowly-changing dimension
-- activation enabled
left join (select on_what_id AS partner_id,
	          new_value  AS activation_enabled,
		  create_time AS activation_enabled_time
	   from verse.verse_ods_kiva_admin_audit_log
	   where on_what_table = 'partner'
		 and on_what_column = 'activation_enabled') en on en.partner_id = p.id 
		 
-- activation overall limit
left join (select partner_id, 
		  new_value as activation_overall_limit,
		  create_time as activation_overall_limit_time
	   from verse.verse_ods_kiva_activation_overall_limit_history) ol on ol.partner_id = p.id 
	   
-- DAF eligible loans
left join (select on_what_id AS partner_id,
		  new_value  AS loans_are_daf_eligible,
		  create_time AS loans_are_daf_eligible_time
	   from verse.verse_ods_kiva_admin_audit_log
	   where on_what_table = 'partner'
		 and on_what_column  = 'loans_are_daf_eligible') daf on daf.partner_id = p.id

*/
	   
;	   		 