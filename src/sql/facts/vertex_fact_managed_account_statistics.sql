--VERTEX_NO_DEPLOY
CREATE VIEW vertex_fact_managed_account_statistics AS

SELECT fact_cc.effective_day_id,
       ma.managed_account_id,
       ma.fund_account_id,
       loan.sector_id,
       loan.partner_id,
       town.country_id AS country_id_ps,
       loan.gender,
       loan.num_entreps,
       fa.current_balance,
       CASE WHEN ((fact_cc.credit_change_type_id = 65) AND (fact_cc.ref_id = 0)) THEN true
            WHEN (loan.status = 'expired') THEN true 
            ELSE false END AS is_expired,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'loan_purchase')) --loan_purchase_credit_change_types 
        THEN (- fact_cc.price) ELSE 0::numeric(18,0) END AS purchase_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'credit_transfer')) -- credit_transfer_credit_change_types
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS transfer_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                WHERE vertex_dim_credit_change_type.reporting_group = 'withdrawal')) -- withdrawal_credit_change_types 
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS withdrawal_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'gift_purchase')) -- gift_purchase_credit_change_types 
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS gift_purchase_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'gift_expiration')) --gift_expiration_credit_change_types 
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS gift_expiration_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'gift_redemption')) --gift_redemption_credit_change_types 
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS gift_redemption_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'ops_credit')) --ops_credit_credit_change_types 
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS ops_credit_amount,
       CASE WHEN (((fact_cc.credit_change_type_id = ANY (ARRAY[65, 70])) AND (fact_cc.ref_id > 2000000)) OR (fact_cc.credit_change_type_id = ANY (ARRAY[26, 52])))
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS repaid_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'currency_loss')) --currency_loss_credit_change_types 
        THEN (- fact_cc.price) ELSE 0::numeric(18,0) END AS fx_loss_amount,
        0 AS default_amount,
       CASE WHEN (((fact_cc.credit_change_type_id = ANY (ARRAY[65, 70])) AND (fact_cc.ref_id < 2000000) AND (fact_cc.price > 0::numeric(18,0))) OR (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = ANY (ARRAY['loan_refund'::varchar(11), 'loan_expiration'])))) --refund_credit_change_types 
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS refunded_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'deposit')) --deposit_credit_change_types 
        THEN fact_cc.price ELSE 0::numeric(18,0) END AS deposit_amount,
       CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT vertex_dim_credit_change_type.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type
                 WHERE vertex_dim_credit_change_type.reporting_group = 'donation' AND vertex_dim_credit_change_type.source_table_name = 'credit_change')) --donation_credit_change_types
        THEN (- fact_cc.price) ELSE 0::numeric(18,0) END AS donation_amount,
        loan.loan_id
        
FROM ((((((vertex_fact_credit_change fact_cc 
JOIN vertex_dim_managed_account ma ON ((fact_cc.fund_account_id = ma.fund_account_id))) 
JOIN vertex_dim_credit_change_type dimcct ON ((dimcct.id = fact_cc.credit_change_type_id))) 
JOIN vertex_dim_fund_account_accounts fa ON ((fa.fund_account_id = ma.fund_account_id))) 
LEFT JOIN verse.verse_ods_kiva_repayment_settled rs ON ((rs.id = fact_cc.ref_id))) 
LEFT JOIN vertex_dim_loan loan ON 
        ((CASE WHEN (fact_cc.credit_change_type_id = ANY (ARRAY[64, 69])) THEN fact_cc.ref_id -- type_name in ('deposit_reversal', 'fundpool_funding')
               WHEN ((fact_cc.credit_change_type_id = ANY (ARRAY[27, 65, 70])) AND (fact_cc.ref_id < 2000000)) THEN fact_cc.ref_id -- type_name in ('m_check_deposit','deposit_hold','fundpool_funding_void')
               WHEN ((fact_cc.credit_change_type_id = 65) AND (fact_cc.ref_id > 2000000)) THEN rs.loan_id  -- type_name in ('deposit_hold')
               WHEN (dimcct.item_refers_to = 'business') THEN fact_cc.item_id 
               WHEN (dimcct.ref_refers_to = 'business') THEN fact_cc.ref_id ELSE NULL::int 
          END = loan.loan_id))) 
LEFT JOIN verse.verse_ods_kiva_town town ON ((loan.geo_id = town.id)))

WHERE (fact_cc.fund_account_id > 0) 

UNION ALL  

SELECT fact_cc.effective_day_id,
        ma.managed_account_id,
        ma.fund_account_id,
        loan.sector_id,
        loan.partner_id,
        town.country_id AS country_id_ps,
        loan.gender,
        loan.num_entreps,
        fa.current_balance,
        CASE WHEN (loan.status = 'expired') THEN true ELSE false END AS is_expired,
        0 AS purchase_amount,
        0 AS transfer_amount,
        0 AS withdrawal_amount,
        0 AS gift_purchase_amount,
        0 AS gift_expiration_amount,
        0 AS gift_redemption_amount,
        0 AS ops_credit_amount,
        0 AS repaid_amount,
        0 AS fx_loss_amount,
        CASE WHEN (fact_cc.credit_change_type_id IN 
        ( SELECT cct.id AS credit_change_type_id
                 FROM vertex_dim_credit_change_type cct
                 WHERE cct.reporting_group = 'loan_default' AND cct.source_table_name = 'ledger_credit_change')) 
             THEN fact_cc.price ELSE 0 END AS default_amount,
        0 AS refunded_amount,
        0 AS donation_amount,
        0 AS deposit_amount,
        loan.loan_id
        
 FROM (((((vertex_fact_ledger_credit_change fact_cc 
 JOIN vertex_dim_managed_account ma ON ((fact_cc.fund_account_id = ma.fund_account_id))) 
 JOIN vertex_dim_credit_change_type dimcct ON ((dimcct.id = fact_cc.credit_change_type_id))) 
 JOIN vertex_dim_fund_account_accounts fa ON ((fa.fund_account_id = ma.fund_account_id))) 
 JOIN vertex_dim_loan loan ON ((loan.loan_id = fact_cc.ref_id))) 
 JOIN verse.verse_ods_kiva_town town ON ((loan.geo_id = town.id)))
 
 WHERE (fact_cc.fund_account_id > 0);


