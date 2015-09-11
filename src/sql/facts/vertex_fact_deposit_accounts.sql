--VERTEX_NO_DEPLOY

create or replace view vertex_fact_deposit_accounts as

with manual_types as (
        select credit_change_type_id from vertex_dim_credit_change_type where type_name like 'm_%'
),
check_types as (
        select credit_change_type_id 
        from vertex_dim_credit_change_type
	where type_name like 'm_check_deposit%'
	and source_table_name = 'credit_change'
),
echeck_types as (
        select credit_change_type_id 
        from vertex_dim_credit_change_type
	where type_name like 'echeck%'
	and source_table_name = 'credit_change'
),
mwire_types as (
        select credit_change_type_id 
        from vertex_dim_credit_change_type
	where type_name like 'm_wire%'
	and source_table_name = 'credit_change'
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
	mref.referrer_id,
	cc.user_account_type,
	cc.accounting_category_id,
	cc.credit_change_type_id,
	case when cc.credit_change_type_id in (select credit_change_type_id from check_types)
	       then true
	       else false
	       end as is_check_deposit, 
	case when cc.credit_change_type_id in (select credit_change_type_id from echeck_types)
	       then true
	       else false
	       end as is_echeck, 
	case when cc.credit_change_type_id in (select credit_change_type_id from mwire_types)
	       then true
	       else false
	       end as is_wire,              
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
           
inner join (select fund_account_id, create_day_id as reg_day_id
	    from vertex_dim_fund_account_accounts) fa on fa.fund_account_id=cc.fund_account_id		
	    
left join (select e.item_id as credit_change_id, min(dim.referrer_id) as referrer_id
           from verse_ods_www_event e
           inner join verse_ods_www_document doc on (e.document_id=doc.v_id AND doc.category='credit_change')
           inner join verse_ods_www_trackingsession ts on ts.v_id=e.trackingsession_id
           inner join verse_ods_www_referrer_clean ref on ref.v_id=ts.referrer_id
           inner join vertex_dim_www_referrer dim on 
                   ref.source=dim.source AND ref.medium=dim.medium AND ref.campaign=dim.campaign AND ref.campaign_content=dim.campaign_content
           group by e.item_id) mref on mref.credit_change_id=cc.credit_change_id	    						          	

where credit_change_type_id in (
        select credit_change_type_id from deposit_types);

