--VERTEX_NO_DEPLOY
/**

Creates fact_loan_purchase.

Note:
	-- repayment_fund_account_id, settlement_type cols empty in the verse, so ommitting them here.
	-- referrer id logic copied from fact deposit accounts.  So, TODO: verify
	-- is_manual, is_modification were always false in the verse, so omitting.

Restricted to cc types 'loan_purchase_auto', 'loan_purchase' in the verse.

 */
create or replace view vertex_fact_loan_purchase as
with
eligible_cc_type_list as (select credit_change_type_id
								from vertex_dim_credit_change_type
								where type_name in ('loan_purchase_auto', 'loan_purchase')),
autoloan_list as ( select credit_change_type_id
                from vertex_dim_credit_change_type
                where type_name = 'loan_purchase_auto' /* this is the autoloan version of loan_purchase */
			and source_table_name = 'credit_change'
),
deposit_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where category = 'deposit'
          and source_table_name = 'credit_change'
	  and type_name not in ('deposit_hold','deposit_hold_cleared')
),
first_purchases as (  /* We use this to figure out when a fund account first added money to their kiva acct, allowing us to put users in buckets existing, activated, new */
        select fund_account_id, min(effective_day_id) as first_effective_day_id
				from vertex_fact_credit_change
				where credit_change_type_id in (
                select credit_change_type_id from deposit_types)
				group by fund_account_id
)
select
		cc.credit_change_id
	, cc.effective_day_id
	, cc.fund_account_id
	, case when (fpt.first_effective_day_id = fa.reg_day_id
				 	and fpt.first_effective_day_id = effective_day_id)
				 then 'new'
				 when  (fpt.first_effective_day_id > fa.reg_day_id
				 	and fpt.first_effective_day_id = effective_day_id)
				 then 'activated'
				 when fpt.first_effective_day_id < effective_day_id
				 then 'existing'
				 else 'undefined'
		end as user_type    /* logic copied from fact_donation_accounts, should probably verify when fact_donation_accounts is deployed */
	, abs(cc.price) as amount /* in the verse, there are no negative amts.  all original amts are negative, all are flipped. */
	, cc.item_id
	, cc.trans_id as transaction_id
	/*, false as is_modification*/
	, cc.credit_change_type_id
	/*, false as is_manual */
	, case when cc.credit_change_type_id in (select credit_change_type_id from autoloan_list)
	       then true
	       else false
	       end as is_autoloan
	, cc.accounting_category_id
	, fdo.credit_change_number
	, fdo.occasion_number
	, fdo.days_since_previous_occasion
	, fdo.amount_of_previous_occasion
	, b.id as loan_id
	, b.partner_id
	, mref.referrer_id
from vertex_fact_credit_change cc
inner join (select fund_account_id, first_effective_day_id
            from first_purchases
           ) fpt on fpt.fund_account_id=cc.fund_account_id
inner join (select fund_account_id, create_day_id as reg_day_id
	    from vertex_dim_fund_account_accounts) fa on fa.fund_account_id=cc.fund_account_id
left join business b on cc.item_id = b.id
left join vertex_fact_deposit_occasion fdo on fdo.credit_change_id = cc.credit_change_id
left join (select e.item_id as credit_change_id, min(dim.referrer_id) as referrer_id
           from verse_ods_www_event e
           inner join verse_ods_www_document doc on (e.document_id=doc.v_id AND doc.category='credit_change')
           inner join verse_ods_www_trackingsession ts on ts.v_id=e.trackingsession_id
           inner join verse_ods_www_referrer_clean ref on ref.v_id=ts.referrer_id
           inner join vertex_dim_www_referrer dim on
                   ref.source=dim.source AND ref.medium=dim.medium AND ref.campaign=dim.campaign AND ref.campaign_content=dim.campaign_content
           group by e.item_id) mref on mref.credit_change_id=cc.credit_change_id /*logic copied from vertex_fact_deposit_accounts*/
where cc.credit_change_type_id in (select credit_change_type_id from eligible_cc_type_list);