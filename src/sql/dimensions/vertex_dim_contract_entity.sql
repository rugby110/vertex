/*
I'm adding the extra row from the verse, because it looks like it has more meaning than the generic 'null' case
 */
create or replace view vertex_dim_contract_entity as
select -1 as contract_entity_id,
	'Self-Directed Lender' as name ,
	1 as src_of_funds_id
UNION
select distinct
	id as contract_entity_id,
	name,
	src_of_funds_id
from contract_entity
order by contract_entity_id
