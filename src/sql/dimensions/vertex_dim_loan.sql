/**
TODO:  move measures to _vertex_fact_loan?
 */
create or replace view vertex_dim_loan as

select l.id as loan_id,
        l.price as price_usd,
        l.status,
        l.lender_term, 
        l.currency, 
        l.risk_policy_currency,
        l.loan_theme_instance_id,
        l.daf_eligible,
	b.id as business_id,
	b.activity_id,
	b.partner_id,
	case when b.video_id>0 then 1 else 0 end as has_video_profile,
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
	COALESCE(LENGTH(b.description) - LENGTH(REPLACE(b.description, ' ', ''))+1, 0) as description_word_count,
	l.create_time,
	TO_CHAR(TO_TIMESTAMP(l.create_time), 'YYYYMMDD')::INT as create_day_id,
	l.inactive_expired_time,
	TO_CHAR(TO_TIMESTAMP(l.inactive_expired_time), 'YYYYMMDD')::INT as inactive_expired_day_id,
	l.fund_raising_time,
	TO_CHAR(TO_TIMESTAMP(l.fund_raising_time), 'YYYYMMDD')::INT as fund_raising_day_id,
	l.expired_time,
	TO_CHAR(TO_TIMESTAMP(l.expired_time), 'YYYYMMDD')::INT as expired_day_id,
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
	TO_CHAR(TO_TIMESTAMP(l.issue_time), 'YYYYMMDD')::INT as issue_day_id,
	l.defaulted_time,
	TO_CHAR(TO_TIMESTAMP(l.defaulted_time), 'YYYYMMDD')::INT as defaulted_day_id,
	l.planned_expiration_time,
	TO_CHAR(TO_TIMESTAMP(l.planned_expiration_time), 'YYYYMMDD')::INT as planned_expiration_day_id,
	l.planned_inactive_expire_time,
	TO_CHAR(TO_TIMESTAMP(l.planned_inactive_expire_time), 'YYYYMMDD')::INT as planned_inactive_expire_day_id,
	COALESCE(sp_num.sp_num_badges, 0) as sp_num_badges,
	sp.sp_badges,
	case when sp.sp_badges like '%Anti-Poverty Focus%' then true else false end as sp_anti_poverty_focus,
	case when sp.sp_badges like '%Vulnerable Group Focus%' then true else false end as sp_vulnerable_group_focus,
	case when sp.sp_badges like '%Client Voice%' then true else false end as sp_client_voice,
	case when sp.sp_badges like '%Family and Community Empowerment%' then true else false end as sp_family_and_community_empowerment,
	case when sp.sp_badges like '%Entrepreneurial Support%' then true else false end as sp_entrepreneurial_support,
	case when sp.sp_badges like '%Facilitation of Savings%' then true else false end as sp_facilitation_of_savings,
	case when sp.sp_badges like '%Innovation%' then true else false end as sp_innovation,
	am.sector_id,
	t.id as geo_id,
	ltt.name as loan_theme_type_name,
	b.distribution_model,
	bl.id as relisting_id,
	COALESCE(entreps.num_entreps, 0) as num_entreps,
	entreps.gender,
	COALESCE(entreps.gender_num_male, 0) as gender_num_male,
	COALESCE(entreps.gender_num_female, 0) as gender_num_female,
	COALESCE(entreps.gender_num_unspecified, 0) as gender_num_unspecified,
	COALESCE(jrnls.num_journals_total, 0) as num_journals_total,
	COALESCE(jrnls.num_journals_rate_eligible, 0) as num_journals_rate_eligible,
	COALESCE(jrnls.num_journals_rate_ineligible, 0) as num_journals_rate_ineligible,
	COALESCE(shares.shares_purchased_num, 0) as shares_purchased_num,
        COALESCE(shares.shares_purchased_total, 0) as shares_purchased_total,
	TO_CHAR(TO_TIMESTAMP(shares.shares_purchased_first_time), 'YYYYMMDD')::INT as shares_purchased_first_day_id,
	TO_CHAR(TO_TIMESTAMP(shares.shares_purchased_last_time), 'YYYYMMDD')::INT as shares_purchased_last_day_id,
	COALESCE(re.num_repayment_expected, 0) as num_repayment_expected,
	TO_CHAR(TO_TIMESTAMP(re.final_repayment_expected_time), 'YYYYMMDD')::INT as final_repayment_expected_day_id,
	TO_CHAR(re.default_limit_timestamp, 'YYYYMMDD')::INT as default_limit_day_id,
	COALESCE(rs.settled_num, 0) as settled_num,
        COALESCE(rs.settled_total, 0) as settled_total,
        TO_CHAR(TO_TIMESTAMP(rs.settled_first_time), 'YYYYMMDD')::INT as settled_first_day_id,
        TO_CHAR(TO_TIMESTAMP(rs.settled_last_time), 'YYYYMMDD')::INT as settled_last_day_id,
        COALESCE(rs.currency_loss_lenders_num, 0) as currency_loss_lenders_num,
        COALESCE(rs.currency_loss_lenders_total, 0) as currency_loss_lenders_total,
        TO_CHAR(TO_TIMESTAMP(rs.currency_loss_lenders_first_time), 'YYYYMMDD')::INT as currency_loss_lenders_first_day_id,
        TO_CHAR(TO_TIMESTAMP(rs.currency_loss_lenders_last_time), 'YYYYMMDD')::INT as currency_loss_lenders_last_day_id
	
	

from loan l

inner join business b on b.id=l.business_id
left join activity_mapper am on am.activity_id=b.activity_id
left join town t on t.id=b.town_id
left join loan_theme_type ltt on ltt.id=l.loan_theme_type_id
left join business_link bl on bl.to_business_id=b.id

left join (select l.id as loan_id, 
                GROUP_CONCAT(s.name) 
                over (partition by l.id) as sp_badges
           from loan l
           inner join business b on b.id=l.business_id
           inner join partner_sp_strength_mapper sm on sm.partner_id=b.partner_id AND sm.create_time <= l.raised_time
           inner join partner_sp_strength s on s.id=sm.strength_id
           where sm.active
           ) sp on sp.loan_id = l.id
           
left join (select l.id as loan_id, -- can't add anything else with over clause, above
           count(1) as sp_num_badges
           from loan l
           inner join business b on b.id=l.business_id
           inner join partner_sp_strength_mapper sm on sm.partner_id=b.partner_id AND sm.create_time <= l.raised_time
           inner join partner_sp_strength s on s.id=sm.strength_id
           where sm.active
           group by l.id
           ) sp_num on sp_num.loan_id = l.id           

 -- Entreps
left join (select business_id, coalesce(count(distinct em.person_id),0) as num_entreps,
 		  case 
 		     when sum(case when p.gender='male' then 1 else 0 end) >= sum(case when p.gender in('female','unspecified') then 1 else 0 end) 
 		     then 'male' else 'female' end 
 		     as gender,
		  sum(case when p.gender='male' then 1 else 0 end) as gender_num_male,
		  sum(case when p.gender='female' then 1 else 0 end) as gender_num_female,
		  sum(case when p.gender='unspecified' then 1 else 0 end) as gender_num_unspecified
	   from entrep_mapper em
	   left join person p on p.id = em.person_id
	   group by business_id) entreps on entreps.business_id = l.business_id	
		  
-- Journals
left join (select business_id,
		  count(1) as num_journals_total,
                  count(case when type='single_loan' or type='relisting' then 1 else null end) as num_journals_rate_eligible,
                  count(case when type='single_loan' or type='relisting' then null else 1 end) as num_journals_rate_ineligible
           from journal_entry
           group by business_id) jrnls on jrnls.business_id = l.business_id		  		     
           
-- SharesPurchased
left join (select loan_id, 
                  count(1) as shares_purchased_num,
                  sum(purchase_amt) as shares_purchased_total,
		  min(purchase_time) as shares_purchased_first_time,
		  max(purchase_time) as shares_purchased_last_time
            from lender_loan_purchase
	    group by loan_id) shares on shares.loan_id = l.id     
	    
-- RepaymentExpected
left join (select loan_id,
                  count(1) as num_repayment_expected,
		  max(effective_time) as final_repayment_expected_time,
		  ADD_MONTHS(TO_TIMESTAMP(max(effective_time)), 6) as default_limit_timestamp
           from repayment_expected
	   group by loan_id) re on re.loan_id = l.id  
		  
-- RepaymentSettled
left join (select loan_id, 
                  count(1) as settled_num,
                  sum(settled_price) as settled_total,
                  min(settlement_time) as settled_first_time,
                  max(settlement_time) as settled_last_time,
                  sum(case when settled_currency_loss_lenders>0 then 1 else 0 end) as currency_loss_lenders_num,
                  sum(settled_currency_loss_lenders) as currency_loss_lenders_total,
                  min(case when settled_currency_loss_lenders>0 then settlement_time else null end) as currency_loss_lenders_first_time,
                  max(case when settled_currency_loss_lenders>0 then settlement_time else null end) as currency_loss_lenders_last_time
           from repayment_settled
	   group by loan_id) rs on rs.loan_id=l.id	  

;

