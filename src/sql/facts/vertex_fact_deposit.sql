--VERTEX_NO_DEPLOY

create or replace view vertex_fact_deposit as

with grouped_credit_change_type_ids as (
        select credit_change_type_id 
        from vertex_dim_credit_change_type
	where (type_name='deposit' or type_name='echeck_deposit')
	and source_table_name = 'credit_change'
)
select credit_change_id, 
credit_change_number, 
occasion_number,
sum(zeroifnull(date_diff*first_row_of_occasion)) over (partition by fund_account_id, effective_day_id order by effective_time) as days_since_previous_occasion,
sum(zeroifnull(amount_of_previous_occasion_step1*first_row_of_occasion)) over (partition by fund_account_id, effective_day_id order by effective_time) as amount_of_previous_occasion
from (
        select credit_change_id, 
                fund_account_id, 
                effective_day_id, 
                effective_time, 
                credit_change_number, 
                occasion_number,
                ABS (DATEDIFF ('dd',TO_DATE(effective_day_id::varchar, 'YYYYMMDD'), TO_DATE(lag_edi::varchar, 'YYYYMMDD'))) as date_diff,
                lag(occasion_amount_sum) over (partition by fund_account_id order by effective_time) as amount_of_previous_occasion_step1,
                CASE (effective_day_id_diff > 0)
                        WHEN true THEN 1
                        WHEN false THEN 0
                        ELSE 1
                END as first_row_of_occasion
        from (
 
           select  credit_change_id, 
                fund_account_id, 
                effective_day_id, 
                effective_time,
                sum(amount) over (partition by fund_account_id, effective_day_id order by effective_time) as occasion_amount_sum,
                conditional_true_event(true) over (partition by fund_account_id order by effective_time) as credit_change_number,
                conditional_true_event((effective_day_id - lag(effective_day_id) > 0) or (lag(effective_day_id) is null)) over (partition by fund_account_id order by effective_time) as occasion_number,
                effective_day_id - lag(effective_day_id)  over (partition by fund_account_id order by effective_time) as effective_day_id_diff,
                lag(effective_day_id)  over (partition by fund_account_id  order by effective_time) as lag_edi
           from vertex_fact_deposit_accounts --$source_table
            
           where credit_change_type_id in (select credit_change_type_id from grouped_credit_change_type_ids)
	   /* remove me */and fund_account_id = 1803146		
           ) as t1
)       as t2

UNION ALL

select credit_change_id, 
        credit_change_number, 
        occasion_number,        
        sum(zeroifnull(date_diff*first_row_of_occasion)) over (partition by fund_account_id, credit_change_type_id, effective_day_id order by effective_time) as v_days_since_previous_occasion,
        sum(zeroifnull(amount_of_previous_occasion_step1*first_row_of_occasion)) over (partition by fund_account_id, credit_change_type_id, effective_day_id order by effective_time) as v_amount_of_previous_occasion
from (
        select credit_change_id, 
                fund_account_id, 
                credit_change_type_id, 
                effective_day_id, 
                effective_time, 
                credit_change_number, 
                occasion_number,
                ABS (DATEDIFF ('dd',TO_DATE(effective_day_id::varchar, 'YYYYMMDD'), TO_DATE(lag_edi::varchar, 'YYYYMMDD'))) as date_diff,
                lag(occasion_amount_sum) over (partition by fund_account_id, credit_change_type_id order by effective_time) as amount_of_previous_occasion_step1,
                CASE (effective_day_id_diff > 0)
                        WHEN true THEN 1
                        WHEN false THEN 0
                        ELSE 1
                END as first_row_of_occasion
                from (
                
                   select credit_change_id, 
                        fund_account_id, 
                        credit_change_type_id, 
                        effective_day_id, 
                        effective_time,
                        sum(amount) over (partition by fund_account_id, credit_change_type_id, effective_day_id order by effective_time) as occasion_amount_sum,
                        conditional_true_event(true) over (partition by fund_account_id, credit_change_type_id order by effective_time) as credit_change_number,
                        conditional_true_event((effective_day_id - lag(effective_day_id) > 0) or (lag(effective_day_id) is null)) over (partition by fund_account_id, credit_change_type_id order by effective_time) as occasion_number,
                        effective_day_id - lag(effective_day_id)  over (partition by fund_account_id, credit_change_type_id order by effective_time) as effective_day_id_diff,
                        lag(effective_day_id)  over (partition by fund_account_id, credit_change_type_id order by effective_time) as lag_edi
                   from vertex_fact_deposit_accounts
                   where credit_change_type_id not in (select credit_change_type_id from grouped_credit_change_type_ids)
                   /* remove me */and fund_account_id = 1803146
        ) as t1
) as t2;