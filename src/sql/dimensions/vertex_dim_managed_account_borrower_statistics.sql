--VERTEX_NO_DEPLOY
create or replace view vertex_dim_managed_account_borrower_statistics as
 
with cc as (
     with loan_purchase_credit_change_types as (
        select credit_change_type_id
        from vertex_dim_credit_change_type
        where reporting_group = 'loan_purchase'
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
            loan.loan_id
        FROM
            vertex_fact_credit_change fact_cc
        INNER JOIN vertex_dim_managed_account ma ON fact_cc.fund_account_id = ma.fund_account_id
        INNER JOIN vertex_dim_credit_change_type dimcct ON dimcct.credit_change_type_id = fact_cc.credit_change_type_id
        INNER JOIN vertex_fact_fund_account fa ON fa.fund_account_id = ma.fund_account_id
        LEFT JOIN vertex_dim_loan loan ON
            CASE
                WHEN fact_cc.credit_change_type_id IN (71, -- fundpool_match
                                                           76) -- kivapool_match
                THEN ref_id
                WHEN fact_cc.credit_change_type_id = 26  -- loan_repayment_currency_loss
                        AND fact_cc.ref_id < 2000000
                THEN ref_id
                WHEN dimcct.item_refers_to = 'business'
                THEN item_id
                WHEN dimcct.ref_refers_to = 'business'
                THEN ref_id
                ELSE NULL
            END = loan.loan_id
        LEFT JOIN town ON loan.geo_id = town.id
        WHERE
            fact_cc.fund_account_id > 0
)
select distinct 
            min(effective_day_id) as effective_day_id,
            sum(purchase_amount) as purchase_amount,
            managed_account_id,
            fund_account_id,
            sector_id,
            partner_id,
            country_id_ps,
            gender,
            num_entreps,
            is_expired,
            loan_id

from cc
where  purchase_amount > 0
group by
            managed_account_id,
            fund_account_id,
            sector_id,
            partner_id,
            country_id_ps,
            gender,
            num_entreps,
            is_expired,
            loan_id;