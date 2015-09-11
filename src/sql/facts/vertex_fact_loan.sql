/**
Creates vertex_fact_loan

TODO: how do we get the most utility out of this, as (currently, and seemingly incorrectly) a subset of vertex_dim_loan

TODO: get measures out of vertex_dim_loan
*/

create or replace view vertex_fact_loan as
select
/*key*/
loan_id

/* aggregatable values */
,price_usd
,lender_term
,description_word_count
,num_entreps
,gender_num_male
,gender_num_female
,gender_num_unspecified
,num_journals_total
,num_journals_rate_eligible
,num_journals_rate_ineligible
,shares_purchased_num
,shares_purchased_total
,num_repayment_expected
,settled_num
,settled_total
,currency_loss_lenders_num
,currency_loss_lenders_total

/*dim ids*/
,loan_theme_instance_id
,activity_id
,partner_id
,reviewer_id
,description_language_id
,sector_id
,geo_id
,relisting_id

/*time dim ids*/
,create_day_id
,inactive_expired_day_id
,fund_raising_day_id
,expired_day_id
,raised_day_id
,paying_back_day_id
,ended_day_id
,deleted_day_id
,refunded_day_id
,reviewed_day_id
,issue_day_id
,defaulted_day_id
,planned_expiration_day_id
,planned_inactive_expire_day_id
,shares_purchased_first_day_id
,shares_purchased_last_day_id
,final_repayment_expected_day_id
,default_limit_day_id
,settled_first_day_id
,settled_last_day_id
,currency_loss_lenders_first_day_id
,currency_loss_lenders_last_day_id
from vertex_dim_loan