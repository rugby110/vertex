create or replace view vertex_dim_fund_account_accounts as

select lfam.login_id as owner_login_id,
	fa.id as fund_account_id,
	uat.id as user_account_type_id, -- The user_account_type_id is selected again for naming convention, to help with dimension column. This actually higlight poor name in KIVA db as well. user_account_type should really be user_account_type_id
	uat.name as user_account_type,
	src_fund.name as source_of_funds,
	fa.accounting_category,
	dac.accounting_category_id,
	lfam.is_default_account,
	fa.create_time,
	TO_CHAR(TO_TIMESTAMP(fa.create_time), 'YYYYMMDD')::INT as create_day_id,
	fa.donate_on_repayment='yes' as donate_on_repayment,
	fa.balance                   as current_balance,
	fa.is_closed='yes'           as is_closed,
	fa.withdrawable='yes'        as is_withdrawable,
	fa.inactive_credit_recipient,
	fa.billing_contact_id        as contact_info_id, -- for dimension column
	fa.billing_contact_id, -- For intermediate column - just for easy debugging
	fa.type_id as fund_account_type_id,
	COALESCE(contact_info.country_id, 0) as country_id,
	COALESCE(geo_state_codes.id, 0) as geo_state_codes_id,
	port.current_portfolio_num,
	port.current_portfolio_total,
	port.e_current_portfolio_outstanding,
	port.e_current_portfolio_repaid


from fund_account fa
inner join login_fund_account_mapper lfam on fa.id = lfam.fund_account_id
inner join vertex_dim_accounting_category dac on dac.accounting_category = fa.accounting_category
left join user_account_type uat on fa.user_account_type = uat.id
left join source_of_funds src_fund on fa.source_of_funds = src_fund.id
left join contact_info contact_info on contact_info.id=fa.billing_contact_id
left join geo_state_codes geo_state_codes on geo_state_codes.postal_code = contact_info.state and contact_info.country_id = 227

-- portfolio aggregates:
left join (select fa.id as fund_account_id,
			count(distinct l.id) as current_portfolio_num,
			sum(llp.purchase_amt)          as current_portfolio_total,
			sum((llp.purchase_amt/l.price) * (l.price-rs.settled_total)) as e_current_portfolio_outstanding,
			sum((llp.purchase_amt/l.price) * (rs.settled_total))             as e_current_portfolio_repaid
        from fund_account fa
        inner join lender_loan_purchase llp on llp.lender_fund_account_id=fa.id
        inner join loan l on l.id=llp.loan_id and l.status in ('payingBack','raised','fundRaising')
        left join (select loan_id, sum(settled_price) as settled_total
                        from repayment_settled
                        group by loan_id) rs on rs.loan_id = l.id
        group by fa.id) port on port.fund_account_id = fa.id


where lfam.is_owner = 'yes' ;
