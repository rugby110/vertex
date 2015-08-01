--VERTEX_NO_DEPLOY
create or replace view vertex_fact_promo_impact as

select pi.managed_account_id, pi.acquired_fund_account_id, pi.acquired_login_id, pi.promo_type, pi.acquired_time, pi.acquired_day_id, pi.is_existing_user, pi.is_existing_lender, pi.is_existing_depositor, pi.is_existing_donor, pi.is_existing_card_purchaser, pi.promo_amt_required/ma.promo_price as num_redeemed_per_user,
                pi.promo_amt_required,
               ccf.marginal_amt_lent as  marginal_amt_lent,
                ccf.marginal_amt_deposited as marginal_amt_deposited, ccf.marginal_amt_donated as marginal_amt_donated, ccf.marginal_amt_withdrawn as marginal_amt_withdrawn, ccf.marginal_amt_kivacard_purchase as marginal_amt_kivacard_purchase

from vertex_fact_promo_impact_accounts pi
left join (select managed_account_id, fund_account_id, sum(marginal_amt_lent) as marginal_amt_lent, sum(marginal_amt_deposited) as marginal_amt_deposited, sum(marginal_amt_donated) as marginal_amt_donated, sum(marginal_amt_withdrawn) as marginal_amt_withdrawn, sum(marginal_amt_kivacard_purchase) as marginal_amt_kivacard_purchase
        from vertex_fact_promo_impact_marginal_amounts
        group by managed_account_id, fund_account_id ) ccf
        on pi.acquired_fund_account_id = ccf.fund_account_id and pi.managed_account_id = ccf.managed_account_id
inner join vertex_dim_managed_account ma on pi.managed_account_id = ma.fund_account_id;
