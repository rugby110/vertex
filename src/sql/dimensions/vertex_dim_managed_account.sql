--VERTEX_NO_DEPLOY
create or replace view vertex_dim_managed_account as

select TO_CHAR(ma.fund_account_id) || TO_CHAR('_') || COALESCE(TO_CHAR(pf.id), 'NA') as managed_account_id,
			ma.fund_account_id as fund_account_id,
			ce.id as contract_entity_id,
			ce.name as contract_entity_name,
			ce.account_manager_id as account_manager_id,
			TO_CHAR(p.firstName) || TO_CHAR(' ') || TO_CHAR(p.lastName) as account_manager_name,
			ma.management_type as management_type,
			ce.src_of_funds_id as src_of_funds_id,
			fa.dim_user_account_type_id as dim_user_account_type_id,
			fa.accounting_category,
			fa.dim_accounting_category_id,
			pf.id as promo_fund_id,
			pf.code_name as promo_fund_code_name,
			pf.display_name as promo_fund_display_name,
			pg.code_name as promo_group_code_name,
			pg.display_name as promo_group_display_name,
			pf.promo_price as promo_price,
			pf.redemption_max as promo_redemption_max,
			pf.redeemed_amount as promo_redeemed_amt,
			pg.id as promo_group_id,
			pg.type as promo_group_type,
			pg.team_id as team_id,
			fa.fundpool_match_total + fa.kivapool_match_total + fa.loan_purchase_total + fa.loan_purchase_auto_total as total_amount_disbursed,
			fa.loan_repayment_total + fa.fundpool_repayment_total + fa.kivapool_repayment_total as total_amount_repaid,
			fa.donation_total + fa.donation_auto_total - fa.donation_modification_total as total_amount_donated,
			fa.loan_repayment_currency_loss_total + fa.loan_default_total as total_amount_lost,
			fa.loan_refund_total + fa.loan_expired_total as total_amount_refunded,
			fa.loan_purchase_num + fa.loan_purchase_auto_num + fa.fundpool_match_num + fa.kivapool_match_num - fa.loan_refund_num - fa.loan_expired_num as number_loans
from verse_ods_kiva_managed_account ma
inner join verse_ods_kiva_contract_entity ce on ma.contract_entity_id = ce.id
inner join verse_dim_fund_account fa on ma.fund_account_id = fa.fund_account_id
left join verse_ods_kiva_login lo on ce.account_manager_id = lo.id
left join verse_ods_kiva_person p on lo.person_id = p.id
left join verse_ods_kiva_promo_fund pf on fa.fund_account_id = pf.fund_account_id
left join  verse_ods_kiva_promo_group pg on pf.promo_group_id = pg.id
--include where clause?? see CS-4616, exclude Kiva loan share recapture accounts because of MySQL BigInt overflow problem
--where fa.fund_account_id not in (1155230, 1155231)