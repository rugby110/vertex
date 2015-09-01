create or replace view vertex_dim_fund_account_first_item_ids as

select fund_account_id, 
  min(case when type_name = 'fundpool_match' and effective_time = min_eff_time
    then item_id end) as fundpool_match_first_item_id,
  min(case when type_name = 'kivapool_match' and effective_time = min_eff_time
    then item_id end) as kivapool_match_first_item_id   
   
  from ( select fund_account_id, cc.credit_change_type_id as type_id, cct.type_name, item_id, effective_time, min(effective_time)
         over (partition by fund_account_id, cc.credit_change_type_id) min_eff_time
         from vertex_fact_credit_change cc
         inner join vertex_dim_credit_change_type cct on cc.credit_change_type_id = cct.credit_change_type_id
         where cc.credit_change_type_id in
                (select credit_change_type_id
                from vertex_dim_credit_change_type 
                where type_name in ('fundpool_match','kivapool_match'))
         ) min_times
        
where effective_time = min_eff_time

group by fund_account_id; 