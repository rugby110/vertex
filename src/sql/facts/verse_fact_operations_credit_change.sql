create or replace view vertex_fact_operations_credit_change as

select id as operations_credit_change_id,
  admin_user_id,
  price
  create_time,
	TO_CHAR(TO_TIMESTAMP(create_time), 'YYYYMMDD')::INT as create_day_id,
	effective_time,
	TO_CHAR(TO_TIMESTAMP(effective_time), 'YYYYMMDD')::INT as effective_day_id,
  type_id as credit_change_type_id,
  pp_txn_id
from operations_credit_change occ
;

