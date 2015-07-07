create or replace view vertex_fact_promo_impact_accounts as

-- @todo - add acquired_login_id when fund_account_mapper takes effect
select  llp.lender_fund_account_id as acquired_fund_account_id, llp.lender_fund_account_id as acquired_login_id, ma.fund_account_id as managed_account_id, ma.management_type as promo_type,
  min(llp.purchase_time) as acquired_time, TO_CHAR(TO_TIMESTAMP(min(llp.purchase_time)),'YYYYMMDD') as acquired_day_id,
  sum(llp.purchase_amt) as promo_amt_required,
  case when fa.cc_all_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(llp.purchase_time)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_user,
  case when fa.loan_purchase_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(llp.purchase_time)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_lender,
  case when fa.deposit_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(llp.purchase_time)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_depositor,
  case when fa.donation_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(llp.purchase_time)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_donor,
  case when fa.gift_purchase_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(llp.purchase_time)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_card_purchaser
from verse_ods_kiva_lender_loan_purchase llp
inner join vertex_dim_managed_account ma on llp.repayment_fund_account_id = ma.fund_account_id
inner join verse_dim_fund_account fa on fa.fund_account_id=llp.lender_fund_account_id and fa.v_current
where llp.settlement_type in ('promo', 'proxy_credit')
and ma.management_type in ('promo_card', 'free_trial')
group by llp.lender_fund_account_id, ma.fund_account_id, ma.management_type, fa.cc_all_first_day_id, fa.loan_purchase_first_day_id, fa.deposit_first_day_id, fa.donation_first_day_id, fa.gift_purchase_first_day_id

union distinct

-- @todo - i.invitee_id = lfam.login_id -> map to login_id when fund_account_mapper takes effect, uncomment verse_ods_kiva_login_fund_account_mapper below
-- ->innerJoin('verse_ods_kiva_login_fund_account_mapper lfam' , "i.invitee_id = lfam.login_id and lfam.is_owner = 'yes'")
select i.invitee_id as acquired_fund_account_id, i.invitee_id as acquired_login_id, pf.fund_account_id as managed_account_id, 'bonus' as promo_type,
 min(lpci.date_confirmed) as acquired_time, TO_CHAR(TO_TIMESTAMP(min(lpci.date_confirmed)),'YYYYMMDD') as acquired_day_id,
 sum(lpci.amount_at_creation - lpci.amount_unredeemed) as promo_amt_required,
 case when fa.cc_all_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(lpci.date_confirmed)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_user, /* from invitee */
 case when fa.loan_purchase_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(lpci.date_confirmed)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_lender,
 case when fa.deposit_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(lpci.date_confirmed)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_depositor,
 case when fa.donation_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(lpci.date_confirmed)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_donor,
 case when fa.gift_purchase_first_day_id < TO_NUMBER(TO_CHAR(TO_TIMESTAMP(min(lpci.date_confirmed)),'YYYYMMDD'),'99999999') then 1 else 0 end as is_existing_card_purchaser
 from verse_ods_kiva_invitation i
 inner join verse_ods_kiva_lender_promo_credit lpc on i.inviter_id = lpc.lender_account_id and i.created_as_type = 'invite' and i.id = lpc.ref_id
 inner join verse_ods_kiva_promo_fund pf on pf.id = lpc.promo_fund_id and lpc.award_type = 'invitation' and lpc.amount_at_creation-lpc.amount_unredeemed > 0
 inner join verse_dim_fund_account fa on fa.fund_account_id=i.invitee_id and fa.v_current
 inner join (select i.invitee_id, i.date_confirmed, pf.fund_account_id, lpc.amount_at_creation, lpc.amount_unredeemed
        		from verse_ods_kiva_invitation i
        		inner Join verse_ods_kiva_lender_promo_credit lpc on i.inviter_id = lpc.lender_account_id and i.created_as_type = 'invite' and i.id = lpc.ref_id
        		inner Join verse_ods_kiva_promo_fund pf on pf.id = lpc.promo_fund_id
        		where lpc.award_type = 'invitation' and i.created_as_type = 'invite' and lpc.amount_at_creation-lpc.amount_unredeemed > 0)  lpci
	     on i.invitee_id = lpci.invitee_id and pf.fund_account_id = lpci.fund_account_id
			-- inner join verse_ods_kiva_login_fund_account_mapper lfam on t.acquired_fund_account_id = lfam.login_id and lfam.is_owner = 'yes'

group by i.invitee_id, pf.fund_account_id, promo_type, fa.cc_all_first_day_id, fa.loan_purchase_first_day_id, fa.deposit_first_day_id, fa.donation_first_day_id, fa.gift_purchase_first_day_id;

