create or replace view vertex_dim_managed_account as

select TO_CHAR(ma.fund_account_id) || TO_CHAR('_') || COALESCE(TO_CHAR(pf.id), 'NA') as managed_account_id,
			ma.fund_account_id as fund_account_id,
			ce.id as contract_entity_id,
			ce.name as contract_entity_name,
			ce.account_manager_id as account_manager_id,
			TO_CHAR(p.firstName) || TO_CHAR(' ') || TO_CHAR(p.lastName) as account_manager_name,
			ma.management_type as management_type,
			ce.src_of_funds_id as src_of_funds_id,
			fa.user_account_type_id as user_account_type_id,
			fa.accounting_category,
			fa.accounting_category_id,
			pf.id as promo_fund_id,
			pf.code_name as promo_fund_code_name,
			pf.display_name as promo_fund_display_name,
			pg.code_name as promo_group_code_name,
			pg.display_name as promo_group_display_name,
			pf.promo_price as promo_price,
			pf.redemption_max as promo_redemption_max,
			pg.id as promo_group_id,
			pg.type as promo_group_type,
			pg.team_id as team_id
			
from verse.verse_ods_kiva_managed_account ma
inner join verse.verse_ods_kiva_contract_entity ce on ma.contract_entity_id = ce.id
inner join vertex_dim_fund_account fa on ma.fund_account_id = fa.fund_account_id
left join verse.verse_ods_kiva_login lo on ce.account_manager_id = lo.id
left join verse.verse_ods_kiva_person p on lo.person_id = p.id
left join verse.verse_ods_kiva_promo_fund pf on fa.fund_account_id = pf.fund_account_id
left join verse.verse_ods_kiva_promo_group pg on pf.promo_group_id = pg.id
--include where clause?? see CS-4616, exclude Kiva loan share recapture accounts because of MySQL BigInt overflow problem
--where fa.fund_account_id not in (1155230, 1155231)