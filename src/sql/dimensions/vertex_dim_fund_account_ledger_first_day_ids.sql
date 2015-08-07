create or replace view vertex_dim_fund_account_ledger_first_day_ids as

select fund_account_id, 
  min(loan_default_day_id) as loan_default_first_day_id,
  max(loan_default_day_id) as loan_default_last_day_id,
  min(withdrawal_sent_day_id) as withdrawal_sent_first_day_id,
  max(withdrawal_sent_day_id) as withdrawal_sent_last_day_id,
  min(promo_loan_default_day_id) as promo_loan_default_first_day_id,
  max(promo_loan_default_day_id) as promo_loan_default_last_day_id
  
from (        
        select fund_account_id, cct.id as type_id, cct.type_name,
        case when type_name in ('loan_default', 'loan_undefault') then TO_CHAR(TO_TIMESTAMP(effective_time), 'YYYYMMDD')::INT end as loan_default_day_id,
        case when type_name in ('withdrawal_sent', 'lender_check_sent', 'lender_wire_sent', 'lender_check_returned', 'withdrawal_denied', 'fundpool_withdrawal_sent') then TO_CHAR(TO_TIMESTAMP(effective_time), 'YYYYMMDD')::INT end as withdrawal_sent_day_id,
        case when type_name in ('promo_loan_default', 'promo_loan_undefault') then TO_CHAR(TO_TIMESTAMP(effective_time), 'YYYYMMDD')::INT end as promo_loan_default_day_id
        from verse.verse_ods_kiva_ledger_credit_change lcc
        inner join vertex_dim_credit_change_type cct on lcc.type_id = cct.id
        where cct.source_table_name = 'ledger_credit_change'
        and fund_account_id is not null 
 ) day_ids
        
     
group by day_ids.fund_account_id;          