--VERTEX_NO_DEPLOY

create or replace view vertex_fact_deposit_accounts as

with manual_types as (
        select credit_change_type_id from vertex_dim_credit_change_type where type_name like 'm_%'
),
deposit_types as (
        select credit_change_type_id 
        from vertex_dim_credit_change_type
        where category = 'deposit'
          and source_table_name = 'credit_change'
	  and type_name not in ('deposit_hold','deposit_hold_cleared')
),
first_purchases as (
        select fund_account_id, min(effective_day_id) as first_effective_day_id
	from vertex_fact_credit_change
	where credit_change_type_id in (
                select credit_change_type_id from deposit_types)
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
	-- all modifications are negative, "<"  
	case when price < 0
	       then true
	       else false
	       end as is_modification,    
	case when price < 0
	       then -abs(price)
	       else abs(price)
	       end as amount,
	fpt.first_effective_day_id,
	case when (fpt.first_effective_day_id = fa.reg_day_id
		   and fpt.first_effective_day_id = effective_day_id)
	     then 'new'
             when  (fpt.first_effective_day_id > fa.reg_day_id
		   and fpt.first_effective_day_id = effective_day_id)
	     then 'activated'
             when fpt.first_effective_day_id < effective_day_id
	     then 'existing'
	     else 'undefined'
	end as user_type
	          
	
from vertex_fact_credit_change cc

inner join (select fund_account_id, first_effective_day_id
            from first_purchases 
           ) fpt on fpt.fund_account_id=cc.fund_account_id	
           
inner join (select owner_login_id, create_day_id as reg_day_id
	    from vertex_dim_fund_account_accounts) fa on fa.owner_login_id=cc.fund_account_id								          	

where credit_change_type_id in (
        select credit_change_type_id from deposit_types)

/* remove me */ and cc.fund_account_id = 1803146

order by cc.effective_time;

