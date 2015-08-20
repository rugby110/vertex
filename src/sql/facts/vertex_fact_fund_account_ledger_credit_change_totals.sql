create or replace view vertex_fact_fund_account_ledger_credit_change_totals as

select fund_account_id, 
  sum(loan_default_num) as loan_default_num,
  sum(loan_default_total) as loan_default_total,
  sum(withdrawal_sent_num) as withdrawal_sent_num,
  sum(withdrawal_sent_total) as withdrawal_sent_total,
  sum(promo_loan_default_num) as promo_loan_default_num,
  sum(promo_loan_default_total) as promo_loan_default_total
  
from (        
        select fund_account_id, 
        case when type_name in ('loan_default', 'loan_undefault') then COALESCE(count(1),0) end as loan_default_num,
        case when type_name in ('loan_default', 'loan_undefault') then COALESCE(sum(lcc.price),0) end as loan_default_total,
        case when type_name in ('withdrawal_sent', 'lender_check_sent', 'lender_wire_sent', 'lender_check_returned', 'withdrawal_denied', 'fundpool_withdrawal_sent') then COALESCE(count(1),0) end as withdrawal_sent_num,
        case when type_name in ('withdrawal_sent', 'lender_check_sent', 'lender_wire_sent', 'lender_check_returned', 'withdrawal_denied', 'fundpool_withdrawal_sent') then COALESCE(sum(lcc.price),0) end as withdrawal_sent_total,
        case when type_name in ('promo_loan_default', 'promo_loan_undefault') then COALESCE(count(1),0) end as promo_loan_default_num,
        case when type_name in ('promo_loan_default', 'promo_loan_undefault') then COALESCE(sum(lcc.price),0) end as promo_loan_default_total
       
        from verse.verse_ods_kiva_ledger_credit_change lcc
        inner join vertex_dim_credit_change_type cct on lcc.type_id = cct.id
        where cct.source_table_name = 'ledger_credit_change'
        and fund_account_id is not null 
        
        group by fund_account_id, type_name
        ) totals
        
     
group by totals.fund_account_id;          