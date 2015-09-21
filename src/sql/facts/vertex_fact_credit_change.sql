create or replace view vertex_fact_credit_change as 

select
        cc.credit_change_id,
        cc.fund_account_id,
        cc.changer_id,
        cc.changer_type,
        cc.credit_change_type_id,
	cc.price,
	cc.create_time,
	cc.create_day_id,
	cc.effective_time,
	cc.effective_day_id,
	cc.item_id,
	cc.ref_id,
	cc.new_balance,
	cc.user_account_type, 
	cc.accounting_category_id
from
        vertex_fact_credit_change_core cc
left join vertex_fact_credit_change_www_referrer www_ref on www_ref.credit_change_id = cc.credit_change_id

