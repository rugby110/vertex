--VERTEX_NO_DEPLOY

create or replace view vertex_fact_donation as

select  fda.credit_change_id,
        fda.effective_time,
        fda.effective_day_id,
        fda.fund_account_id,
        fda.item_id,
        fda.transaction_id,
        --fda.referrer_id,
        fda.user_account_type,
        fda.accounting_category_id,
        fda.credit_change_type_id,
        fda.is_manual,       
        fda.is_modification,    
	fda.amount,
	fda.user_type,
	fda.is_autoloan, 
	fda.is_kiva_card_expiration,   
	fda.is_icd,   
	fda.is_matcher,    
	fda.is_subscription, 
	fda.is_dedication,      
	fda.is_contract_recovery,
	fda.is_on_repayment,
        fda.is_matched,
        fda.matcher_name,
        fdo.credit_change_number, 
        fdo.occasion_number,
        fdo.days_since_previous_occasion,
        fdo.amount_of_previous_occasion                           
	
from vertex_fact_donation_accounts fda

left join vertex_fact_donation_occasion fdo on fdo.credit_change_id = fda.credit_change_id;