create or replace view vertex_fact_promo_impact_marginal_amounts as
   with deposit_credit_change_types as (
        select v_id as dim_credit_change_type_id
        from verse_dim_credit_change_type_view
        where reporting_group = 'deposit' and source_table_name = 'credit_change'
        ),
        loan_purchase_credit_change_types as (
        select v_id as dim_credit_change_type_id
        from verse_dim_credit_change_type_view
        where reporting_group = 'loan_purchase' and source_table_name = 'credit_change'
        ),
        donation_credit_change_types as (
        select v_id as dim_credit_change_type_id
        from verse_dim_credit_change_type_view
        where reporting_group = 'donation' and source_table_name = 'credit_change'
        ),
        withdrawal_credit_change_types as (
        select v_id as dim_credit_change_type_id
        from verse_dim_credit_change_type_view
        where reporting_group = 'withdrawal' and source_table_name = 'credit_change'
        ),
        gift_purchase_credit_change_types as (
        select v_id as dim_credit_change_type_id
        from verse_dim_credit_change_type_view
        where reporting_group = 'gift_purchase' and source_table_name = 'credit_change'
        ),
        marginal_amounts as (
        select pif.managed_account_id, cc.fund_account_id,
          case when cc.dim_credit_change_type_id IN (select dim_credit_change_type_id from loan_purchase_credit_change_types)
            then cc.price else 0 end as marginal_amt_lent,
          case when cc.dim_credit_change_type_id IN (select dim_credit_change_type_id from deposit_credit_change_types)
            then cc.price else 0 end as marginal_amt_deposited,
          case when cc.dim_credit_change_type_id IN (select dim_credit_change_type_id from donation_credit_change_types)
            then cc.price else 0 end as marginal_amt_donated,
          case when cc.dim_credit_change_type_id IN (select dim_credit_change_type_id from withdrawal_credit_change_types)
            then cc.price else 0 end as marginal_amt_withdrawn,
          case when cc.dim_credit_change_type_id IN (select dim_credit_change_type_id from gift_purchase_credit_change_types)
            then cc.price else 0 end as marginal_amt_kivacard_purchase
          from verse_fact_credit_change cc
          inner join vertex_fact_promo_impact_accounts pif on cc.fund_account_id = pif.acquired_fund_account_id
          where  pif.acquired_time - cc.effective_time < 20
            and cc.dim_credit_change_type_id in (SELECT v_id
                FROM verse_dim_credit_change_type_view
                WHERE reporting_group in ('loan_purchase', 'withdrawal', 'deposit', 'donation', 'gift_purchase') and source_table_name = 'credit_change')
        )
   select managed_account_id, fund_account_id, -sum(marginal_amt_lent) as marginal_amt_lent, -(-sum(marginal_amt_deposited)) as marginal_amt_deposited, -sum(marginal_amt_donated) as marginal_amt_donated, -sum(marginal_amt_withdrawn) as marginal_amt_withdrawn, -sum(marginal_amt_kivacard_purchase) as marginal_amt_kivacard_purchase
   from  marginal_amounts
   group by managed_account_id, fund_account_id, marginal_amt_lent, marginal_amt_deposited, marginal_amt_donated, marginal_amt_withdrawn, marginal_amt_kivacard_purchase;
