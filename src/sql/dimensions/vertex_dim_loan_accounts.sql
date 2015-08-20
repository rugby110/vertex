--VERTEX_NO_DEPLOY
create or replace view vertex_dim_loan_accounts as

select l.id as loan_id,
        l.price as price_usd,
        l.status,
        l.lender_term, 
        l.currency, 
        l.risk_policy_currency,
        --l.loan_theme_type_id, 
        l.loan_theme_instance_id,
	b.id as business_id,
	b.activity_id,
	--b.town_id,
	--b.main_entrep_id,
	b.partner_id,
	b.video_id>0 as has_video_profile,
	b.reviewer_id,
	b.show_entrep_location,
	b.show_entrep_name,
	b.show_reviewer,
	l.review_mode,
	b.issue_code,
	b.issue_text,
	b.issue_reported_by,
	b.issue_feedback_type,
	b.issue_feedback_text,
	b.issue_feedback_time,
	b.internal_client_id,
	b.internal_loan_id,
	b.description_language_id,  --(also language_id)
	LENGTH(b.description) - LENGTH(REPLACE(b.description, ' ', ''))+1 as description_word_count,
	l.create_time,
	TO_CHAR(TO_TIMESTAMP(l.create_time), 'YYYYMMDD')::INT as create_day_id,
	l.inactive_expired_time,
	TO_CHAR(TO_TIMESTAMP(l.inactive_expired_time), 'YYYYMMDD')::INT as inactive_expired_day_id,
	l.fund_raising_time,
	TO_CHAR(TO_TIMESTAMP(l.fund_raising_time), 'YYYYMMDD')::INT as fund_raising_day_id,
	l.expired_time,
	TO_CHAR(TO_TIMESTAMP(l.expired_time), 'YYYYMMDD')::INT as expired_time_day_id,
	l.raised_time,
	TO_CHAR(TO_TIMESTAMP(l.raised_time), 'YYYYMMDD')::INT as raised_day_id,
	l.paying_back_time,
	TO_CHAR(TO_TIMESTAMP(l.paying_back_time), 'YYYYMMDD')::INT as paying_back_day_id,
	l.ended_time,
	TO_CHAR(TO_TIMESTAMP(l.ended_time), 'YYYYMMDD')::INT as ended_day_id,
	l.deleted_time,
	TO_CHAR(TO_TIMESTAMP(l.deleted_time), 'YYYYMMDD')::INT as deleted_day_id,
	l.refunded_time,
	TO_CHAR(TO_TIMESTAMP(l.refunded_time), 'YYYYMMDD')::INT as refunded_day_id,
	l.reviewed_time,
	TO_CHAR(TO_TIMESTAMP(l.reviewed_time), 'YYYYMMDD')::INT as reviewed_day_id,
	l.issue_time,
	TO_CHAR(TO_TIMESTAMP(l.issue_time), 'YYYYMMDD')::INT as issue_time_day_id,
	l.defaulted_time,
	TO_CHAR(TO_TIMESTAMP(l.defaulted_time), 'YYYYMMDD')::INT as defaulted_day_id,
	l.planned_expiration_time,
	TO_CHAR(TO_TIMESTAMP(l.planned_expiration_time), 'YYYYMMDD')::INT as planned_expiration_day_id,
	l.planned_inactive_expire_time,
	TO_CHAR(TO_TIMESTAMP(l.planned_inactive_expire_time), 'YYYYMMDD')::INT as planned_inactive_expire_day_id,
	--str.sp_badges,
	--case when str.sp_badges like '%Anti-Poverty Focus%' then true else false end as sp_anti_poverty_focus,
	--case when str.sp_badges like '%Vulnerable Group Focus%' then true else false end as sp_vulnerable_group_focus,
	--case when str.sp_badges like '%Client Voice%' then true else false end as sp_client_voice_focus,
	--case when str.sp_badges like '%Family and Community Empowerment%' then true else false end as sp_family_and_community_empowerment_focus,
	--case when str.sp_badges like '%Entrepreneurial Support%' then true else false end as sp_entrepreneurial_focus,
	--case when str.sp_badges like '%Facilitation of Savings%' then true else false end as sp_facilitation_of_savings_focus,
	--case when str.sp_badges like '%Innovation%' then true else false end as sp_innovation_focus,
	str.sp_num_badges,
	am.sector_id,
	t.id as geo_id,
	ltt.name as loan_theme_type_name,
	b.distribution_model,
	bl.id as relisting_id

from verse.verse_ods_kiva_loan l

inner join verse.verse_ods_kiva_business b on b.id=l.business_id
left join verse.verse_ods_kiva_activity_mapper am on am.activity_id=b.activity_id
left join verse.verse_ods_kiva_town t  on t.id=b.town_id
left join verse.verse_ods_kiva_loan_theme_type ltt on ltt.id=l.loan_theme_type_id
left join verse.verse_ods_kiva_business_link bl on bl.to_business_id=b.id

left join (select l.id as loan_id, 
           --cast(GROUP_CONCAT(s.name) as char(255)) as sp_badges,
           count(1) as sp_num_badges
           from verse.verse_ods_kiva_loan l
           inner join verse.verse_ods_kiva_business b on b.id=l.business_id
           inner join verse.verse_ods_kiva_partner_sp_strength_mapper sm on sm.partner_id=b.partner_id AND sm.create_time <= l.raised_time
           inner join verse.verse_ods_kiva_partner_sp_strength s on s.id=sm.strength_id
           where sm.active 
           group by l.id) str on str.loan_id = l.id
           

--where l.id = 346856


