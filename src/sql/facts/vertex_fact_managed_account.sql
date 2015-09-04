create or replace view vertex_fact_managed_account as

select TO_CHAR(ma.fund_account_id) || TO_CHAR('_') || COALESCE(TO_CHAR(pf.id), 'NA') as managed_account_id,
			ma.fund_account_id as fund_account_id,
			pf.id as promo_fund_id,
			pf.redeemed_amount as promo_redeemed_amt,
			ffa.fundpool_match_total + ffa.kivapool_match_total + ffa.loan_purchase_total + ffa.loan_purchase_auto_total as total_amount_disbursed,
			ffa.loan_repayment_total + ffa.fundpool_repayment_total + ffa.kivapool_repayment_total as total_amount_repaid,
			ffa.donation_total + ffa.donation_auto_total - ffa.donation_modification_total as total_amount_donated,
			ffa.loan_repayment_currency_loss_total + ffa.loan_default_total as total_amount_lost,
			ffa.loan_refund_total + ffa.loan_expired_total as total_amount_refunded,
			ffa.loan_purchase_num + ffa.loan_purchase_auto_num + ffa.fundpool_match_num + ffa.kivapool_match_num - ffa.loan_refund_num - ffa.loan_expired_num as number_loans
from managed_account ma
inner join vertex_fact_fund_account ffa on ma.fund_account_id = ffa.fund_account_id
left join promo_fund pf on ma.fund_account_id = pf.fund_account_id

--include where clause?? see CS-4616, exclude Kiva loan share recapture accounts because of MySQL BigInt overflow problem
--where fa.fund_account_id not in (1155230, 1155231)