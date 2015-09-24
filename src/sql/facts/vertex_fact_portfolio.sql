create or replace view vertex_fact_portfolio as
with llp_rollup as (
       select llp.loan_id,
       coalesce(llp.team_id,0) as team_id,
       llp.lender_fund_account_id,
       max(llp.purchase_time) as purchase_time,
       sum(llp.purchase_amt) as total
       from lender_loan_purchase llp
       group by loan_id, coalesce(llp.team_id,0),lender_fund_account_id
)
SELECT DISTINCT
				t.loan_id,
				llp.lender_fund_account_id as fund_account_id,
				llp.team_id,
				llp.total,
				TO_CHAR(TO_TIMESTAMP(llp.purchase_time), 'YYYYMMDD')::INT as purchase_day_id,
				t.partner_id,
				t.sector_id,
				t.activity_id,
				t.gender,
				t.geo_id
FROM vertex_dim_loan t
/* Note, i don't think it makes sense to left join this.  If we did, we'd be including loan_ids with no associated llps, which are by definition, not in anyone's portfolio*/
join llp_rollup llp on (llp.loan_id=t.loan_id);
