create or replace view vertex_fact_managed_account_statistics as


with deposit_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'deposit'
),
loan_purchase_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'loan_purchase'
),
gift_purchase_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'gift_purchase'
),
gift_expiration_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'gift_expiration'
),
gift_redemption_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'gift_redemption'
),
ops_credit_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'ops_credit'
),
withdrawal_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'withdrawal'
),
currency_loss_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'currency_loss'
),
refund_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group in ('loan_refund', 'loan_expiration')
),
credit_transfer_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group in ('credit_transfer')
),
donation_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'donation' and source_table_name = 'credit_change'
),
default_ledger_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'loan_default' and source_table_name = 'ledger_credit_change'
)
        SELECT
            fact_cc.effective_day_id,
            ma.managed_account_id,
            ma.fund_account_id,
            loan.sector_id,
            loan.partner_id,
            town.country_id AS country_id_ps,
            loan.gender,
            loan.num_entreps,
            fa.current_balance,
            CASE
                WHEN loan.status = 'expired'
                THEN true
                ELSE false
            END AS is_expired,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from loan_purchase_credit_change_types)
                THEN -price
                ELSE 0
            END AS purchase_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from credit_transfer_credit_change_types)
                THEN price
                ELSE 0
            END AS transfer_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from withdrawal_credit_change_types)
                THEN price
                ELSE 0
            END AS withdrawal_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from gift_purchase_credit_change_types)
                THEN price
                ELSE 0
            END AS gift_purchase_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from gift_expiration_credit_change_types)
                THEN price
                ELSE 0
            END AS gift_expiration_amount,            
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from gift_redemption_credit_change_types)
                THEN price
                ELSE 0
            END AS gift_redemption_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from ops_credit_credit_change_types)
                THEN price
                ELSE 0
            END AS ops_credit_amount,            
            CASE
                WHEN (fact_cc.credit_change_type_id IN (72, -- fundpool_repayment
                                                            77) -- kivapool_repayment
                        AND fact_cc.ref_id > 2000000
                     )
                     OR
                     (fact_cc.credit_change_type_id IN (25, -- loan_repayment
                                                            57) -- promo_loan_reimbursement
                     )
                THEN price
                ELSE 0
            END AS repaid_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from currency_loss_credit_change_types)
                THEN -price
                ELSE 0
            END AS fx_loss_amount,
            0 as default_amount,  -- this comes from ledger_credit_change
            CASE
                WHEN (fact_cc.credit_change_type_id IN (72, -- fundpool_repayment
                                                           77) -- kivapool_repayment
                        AND fact_cc.ref_id < 2000000
                        AND price > 0
                      )
                      OR 
                      (fact_cc.credit_change_type_id IN 
                                (select credit_change_type_id from refund_credit_change_types)
                      )
                THEN price
                ELSE 0
            END AS refunded_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from deposit_credit_change_types)
                THEN price
                ELSE 0
            END AS deposit_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from donation_credit_change_types)
                THEN -price
                ELSE 0
            END AS donation_amount,
            loan.loan_id
        FROM
            vertex_fact_credit_change fact_cc
        INNER JOIN vertex_dim_managed_account ma ON fact_cc.fund_account_id = ma.fund_account_id
        INNER JOIN vertex_dim_credit_change_type dimcct ON dimcct.credit_change_type_id = fact_cc.credit_change_type_id
        INNER JOIN vertex_dim_fund_account fa ON fa.fund_account_id = ma.fund_account_id
        LEFT JOIN repayment_settled rs ON rs.id = ref_id
        LEFT JOIN vertex_dim_loan loan ON
            CASE
                WHEN fact_cc.credit_change_type_id IN (71, -- fundpool_match
                                                           76) -- kivapool_match
                THEN ref_id
                WHEN fact_cc.credit_change_type_id in (26,  -- loan_repayment_currency_loss
                                                           72, -- fundpool_repayment
                                                           77) -- kivapool_repayment
                        AND fact_cc.ref_id < 2000000
                THEN ref_id
                WHEN fact_cc.credit_change_type_id = 72 -- fundpool_repayment
                        AND fact_cc.ref_id > 2000000
                THEN rs.loan_id                
                WHEN dimcct.item_refers_to = 'business'
                THEN item_id
                WHEN dimcct.ref_refers_to = 'business'
                THEN ref_id
                ELSE NULL
            END = loan.loan_id
        LEFT JOIN town town ON loan.geo_id = town.id
        WHERE
            fact_cc.fund_account_id > 0

        UNION ALL

        SELECT
            fact_cc.effective_day_id,
            ma.managed_account_id,
            ma.fund_account_id,
            loan.sector_id,
            loan.partner_id,
            town.country_id AS country_id_ps,
            loan.gender,
            loan.num_entreps,
            fa.current_balance,
            CASE
                WHEN loan.status = 'expired'
                THEN true
                ELSE false
            END   AS is_expired,
            0     AS purchase_amount,
            0     AS transfer_amount,
            0     AS withdrawal_amount,
            0     AS gift_purchase_amount,
            0     AS gift_expiration_amount,
            0     AS gift_redemption_amount,
            0     AS ops_credit_amount,           
            0     AS repaid_amount,
            0     AS fx_loss_amount,
            CASE
                WHEN fact_cc.credit_change_type_id IN (select credit_change_type_id from default_ledger_credit_change_types)
                THEN price
                ELSE 0
            END AS default_amount,
            0     AS refunded_amount,
            0     AS donation_amount,
            0     AS deposit_amount,
            loan.loan_id
        FROM
            vertex_fact_ledger_credit_change fact_cc -- LEDGER_CREDIT_CHANGE!
        INNER JOIN vertex_dim_managed_account ma ON fact_cc.fund_account_id = ma.fund_account_id
        INNER JOIN vertex_dim_credit_change_type dimcct ON dimcct.credit_change_type_id = fact_cc.credit_change_type_id
        INNER JOIN vertex_dim_fund_account fa ON fa.fund_account_id = ma.fund_account_id        
        INNER JOIN vertex_dim_loan loan ON loan.loan_id = fact_cc.ref_id
        INNER JOIN town town ON loan.geo_id = town.id
        WHERE
            fact_cc.fund_account_id > 0;


