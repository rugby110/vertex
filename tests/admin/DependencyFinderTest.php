<?php

use Kiva\Vertex\Admin\DependencyFinder;

class DependencyFinderTest extends PHPUnit_Framework_TestCase {

	public function testForNoDependencies() {
		$sql = "create or replace view vertex_dim_none as

		select * from some_table";

		$expected_dependencies = array();

		$dependency_finder = new DependencyFinder();
		$dependencies = $dependency_finder->getVertexFactDimDependencies("vertex_dim_none", $sql);

		$this->assertSame($expected_dependencies, $dependencies);
	}

	public function testForSingleDependency() {
		$sql = "create or replace view vertex_dim_none as

		select * from vertex_dim_something";

		$expected_dependencies = array("vertex_dim_something");

		$dependency_finder = new DependencyFinder();
		$dependencies = $dependency_finder->getVertexFactDimDependencies("vertex_dim_none", $sql);

		$this->assertSame($expected_dependencies, $dependencies);
	}

	public function testForRemovingDuplicates() {
		$sql = "create or replace view vertex_dim_none as

		select * from vertex_dim_something ds
		inner join vertex_dim_something s on s.id = ds.id
		";

		$expected_dependencies = array("vertex_dim_something");

		$dependency_finder = new DependencyFinder();
		$dependencies = $dependency_finder->getVertexFactDimDependencies("vertex_dim_none", $sql);

		$this->assertSame($expected_dependencies, $dependencies);
	}

	public function testRealSQLWithTwoDependencies() {
		$sql = "create or replace view vertex_fact_zip_borrower_credit_change as

		select bcc.id as zip_credit_change_id,
		  COALESCE(bcc.trans_id,0) as trans_id,
		  bcc.fund_account_id,
		  -- we try to capture the local and USD amounts from the disbursal or repayment_collected references in item_id or
		  -- ref_id and round it to 2 decimal places since it is a currency amount
		  cast(COALESCE(d_on_ref.amount, d_on_item.amount, rc_on_ref.amount, rc_on_item.amount, bcc.price) as numeric(36,2)) as local_price,
		  cast(COALESCE(d_on_ref.amount_usd, d_on_item.amount_usd, rc_on_ref.amount_usd, rc_on_item.amount_usd, bcc.price) as numeric(36,2)) as usd_price,
		  dim_cct.credit_change_type_id,
		  bcc.create_time,
			TO_CHAR(TO_TIMESTAMP(bcc.create_time), 'YYYYMMDD')::INT as create_day_id,
		  bcc.effective_time,
			TO_CHAR(TO_TIMESTAMP(bcc.effective_time), 'YYYYMMDD')::INT as effective_day_id,
		  bcc.item_id,
		  bcc.ref_id,
		  fx.id as fx_rate_id,
		  bcc.changer_id,
		  case
			  when bcc.changer_id = 0 then 'system'
				when bcc.changer_id = bcc.fund_account_id then 'user'
				else 'admin'
			end as changer_type,
			cast(bcc.new_balance as numeric(36,2)) as new_balance,
			-- we try to capture the currency from the disbursal or repayment_collected references in item_id or ref_id, with a
			-- default value of USD
		  COALESCE(d_on_ref.currency, d_on_item.currency, rc_on_ref.currency, rc_on_item.currency, 'USD') as currency,
		  l.country_id,
		  case
			  when fa.contract_entity_id is null then (select id from vertex_dim_accounting_category where accounting_category = 'self_directed')
				else (select id from vertex_dim_accounting_category where accounting_category = 'managed_account')
			end as accounting_category_id
		from verse.verse_ods_zip_credit_change bcc
		inner join verse.verse_ods_zip_fund_accounts fa on fa.id = bcc.fund_account_id
		inner join vertex_dim_credit_change_type dim_cct on dim_cct.credit_change_type_id = bcc.type_id and dim_cct.source_table_name = 'zip.credit_change'
		left join verse.verse_ods_zip_disbursal d_on_ref ON d_on_ref.id = bcc.ref_id AND dim_cct.ref_refers_to = 'disbursal' AND dim_cct.fx_rate_from = 'disbursal'
		left join verse.verse_ods_zip_disbursal d_on_item ON d_on_item.id = bcc.item_id AND dim_cct.item_refers_to = 'disbursal' AND dim_cct.fx_rate_from = 'disbursal'
		left join verse.verse_ods_zip_repayment_collected AS rc_on_ref ON rc_on_ref.id = bcc.ref_id AND dim_cct.ref_refers_to = 'repayment_collected' AND dim_cct.fx_rate_from = 'repayment_collected'
		left join verse.verse_ods_zip_repayment_collected AS rc_on_item ON rc_on_item.id = bcc.item_id AND dim_cct.item_refers_to = 'repayment_collected' AND dim_cct.fx_rate_from = 'repayment_collected'
		-- loan_id can come from either disbursal or repayment_collected
		left join verse.verse_ods_zip_loans l on l.id =
		case
		  when dim_cct.ref_refers_to = 'disbursal' then d_on_ref.loan_id
		  when dim_cct.item_refers_to = 'disbursal' then d_on_item.loan_id
		  when dim_cct.ref_refers_to = 'repayment_collected' then rc_on_ref.loan_id
		  when dim_cct.item_refers_to = 'repayment_collected' then rc_on_item.loan_id
		end
		-- same for fx_rate_id
		left join verse.verse_ods_zip_fx_rates fx ON fx.id =
		case
		  when dim_cct.ref_refers_to = 'disbursal' then d_on_ref.fx_rate_id
		  when dim_cct.item_refers_to = 'disbursal' then d_on_item.fx_rate_id
		  when dim_cct.ref_refers_to = 'repayment_collected' then rc_on_ref.fx_rate_id
		  when dim_cct.item_refers_to = 'repayment_collected' then rc_on_item.fx_rate_id
		end
		where dim_cct.fx_rate_from in ('disbursal', 'repayment_collected') or dim_cct.fx_rate_from is null
		and (dim_cct.ref_refers_to = 'disbursal' or dim_cct.ref_refers_to = 'repayment_collected' or dim_cct.item_refers_to = 'disbursal' or dim_cct.item_refers_to = 'repayment_collected')
		and fa.type = 'BorrowerFundAccount';
		";

		$expected_dependencies = array("vertex_dim_accounting_category","vertex_dim_credit_change_type");

		$dependency_finder = new DependencyFinder();
		$dependencies = $dependency_finder->getVertexFactDimDependencies("vertex_fact_zip_borrower_credit_change", $sql);

		$this->assertSame($expected_dependencies, $dependencies);
	}

}
