--VERTEX_NO_DEPLOY

create or replace view vertex_fact_donation_accounts as

with manual_types as (
        select credit_change_type_id from vertex_dim_credit_change_type where type_name like 'm_%'
),
autoloan_list as ( select credit_change_type_id 
                from vertex_dim_credit_change_type
                where type_name like 'autolend_%'
			and source_table_name = 'credit_change'
),	
kiva_card_expiration_list as ( select credit_change_type_id 
                from vertex_dim_credit_change_type
                where type_name like 'gift_expiration_%'
			and source_table_name = 'credit_change'
),
icd_list as ( select credit_change_type_id 
                from vertex_dim_credit_change_type
                where type_name like 'inactive_credit_%'
			and source_table_name = 'credit_change'
),
matcher_list as ( select credit_change_type_id 
                from vertex_dim_credit_change_type
                where type_name like 'loan_matcher_%'
			and source_table_name = 'credit_change'
),
subscription_list as ( select credit_change_type_id 
                from vertex_dim_credit_change_type
                where type_name like 'subscription_%'
			and source_table_name = 'credit_change'
),
dedication_list as ( select credit_change_type_id 
                from vertex_dim_credit_change_type
                where type_name like 'dedication_%'
			and source_table_name = 'credit_change'
),
contract_recovery_list as ( select credit_change_type_id 
                from vertex_dim_credit_change_type
                where type_name like 'contract_recovery%'
			and source_table_name = 'credit_change'
),
donation_types as (
        select credit_change_type_id 
        from vertex_dim_credit_change_type
        where category = 'donation' and source_table_name = 'credit_change'
),
first_purchases as (
        select fund_account_id, min(effective_day_id) as first_effective_day_id
	from vertex_fact_credit_change
	where credit_change_type_id in (
                select credit_change_type_id from donation_types)
	group by fund_account_id
)

select  cc.credit_change_id,
        cc.effective_time,
        cc.effective_day_id,
        cc.fund_account_id,
        cc.item_id,
        cc.trans_id as transaction_id,
        cc.user_account_type,
        cc.accounting_category_id,
        cc.credit_change_type_id,
        case when cc.credit_change_type_id in (select credit_change_type_id from manual_types)
	       then true
	       else false
	       end as is_manual,
	-- all modifications are positive, ">"       
        case when price > 0
	       then true
	       else false
	       end as is_modification,    
	case when price > 0
	       then -abs(price)
	       else abs(price)
	       end as amount,
	case when (fpt.first_effective_day_id = fa.reg_day_id
		   and fpt.first_effective_day_id = effective_day_id)
	     then 'new'
             when  (fpt.first_effective_day_id > fa.reg_day_id
		   and fpt.first_effective_day_id = effective_day_id)
	     then 'activated'
             when fpt.first_effective_day_id < effective_day_id
	     then 'existing'
	     else 'undefined'
	end as user_type,
	case when cc.credit_change_type_id in (select credit_change_type_id from autoloan_list)
	       then true
	       else false
	       end as is_autoloan, 
	case when cc.credit_change_type_id in (select credit_change_type_id from kiva_card_expiration_list)
	       then true
	       else false
	       end as is_kiva_card_expiration,   
	case when cc.credit_change_type_id in (select credit_change_type_id from icd_list)
	       then true
	       else false
	       end as is_icd,   
	case when cc.credit_change_type_id in (select credit_change_type_id from matcher_list)
	       then true
	       else false
	       end as is_matcher,    
	case when cc.credit_change_type_id in (select credit_change_type_id from subscription_list)
	       then true
	       else false
	       end as is_subscription, 
	case when cc.credit_change_type_id in (select credit_change_type_id from dedication_list)
	       then true
	       else false
	       end as is_dedication,      
	case when cc.credit_change_type_id in (select credit_change_type_id from contract_recovery_list)
	       then true
	       else false
	       end as is_contract_recovery,
	case when cc.changer_id = 0 and  
	       cc.credit_change_type_id not in 
	        (select credit_change_type_id from autoloan_list
	         union
	         select credit_change_type_id from kiva_card_expiration_list
	         union
	         select credit_change_type_id from icd_list
	         union
	         select credit_change_type_id from matcher_list
	         union
	         select credit_change_type_id from subscription_list
	         union
	         select credit_change_type_id from dedication_list
	         union
	         select credit_change_type_id from contract_recovery_list)
	       then true
	       else false
	       end as is_on_repayment,
	       dm.is_matched,
	       dm.matcher_name                              
	
from vertex_fact_credit_change cc

inner join (select fund_account_id, first_effective_day_id
            from first_purchases 
           ) fpt on fpt.fund_account_id=cc.fund_account_id
           
inner join (select owner_login_id, create_day_id as reg_day_id
	    from vertex_dim_fund_account_accounts) fa on fa.owner_login_id=cc.fund_account_id	  
	    
inner join (select kd.id, kd.matcher_id,
                case when kd.matcher_id is not null 
                        then true
                        else false
                        end as is_matched,
                kdm.name as matcher_name
            from donation kd 
            left join donation_matcher kdm on kdm.id=kd.matcher_id
            ) dm on dm.id=cc.item_id             

where credit_change_type_id in (
        select credit_change_type_id from donation_types);

