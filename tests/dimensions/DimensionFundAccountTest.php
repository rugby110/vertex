<?php

class DimensionFundAccountTest extends Kiva\Vertex\Testing\VertexTestCase
{
	public function setUp()
	{
		parent::setUp();
	}

	public function tearDown()
	{
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_fund_account_accounts");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_fund_account");
		$count_from_ods = $result->fetchColumn();

		//echo "count from vertex: " . $count_from_vertex . " count from ods: $count_from_ods\n";

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testIsClosed() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_fund_account_accounts
			where is_closed=true");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_fund_account
			where is_closed = 'yes'");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testCountryIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_fund_account_accounts
			where country_id != 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_ods_kiva_fund_account fa
			left join verse.verse_ods_kiva_contact_info contact_info on contact_info.id=fa.billing_contact_id
			where contact_info.country_id is not null");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testGeoStateCodesIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_fund_account_accounts
			where geo_state_codes_id != 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_ods_kiva_fund_account fa
			left join verse.verse_ods_kiva_contact_info contact_info on contact_info.id=fa.billing_contact_id
			left join verse.verse_ods_kiva_geo_state_codes geo_state_codes on geo_state_codes.postal_code = contact_info.state and contact_info.country_id = 227
			where geo_state_codes.id is not null");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testCurrentPortfolioNum() {
		$result = $this->db->query("select count(1) as how_many, sum(current_portfolio_num) as how_much
			from $this->vertex_schema.vertex_dim_fund_account_accounts
			where current_portfolio_num is not null");
		$from_vertex = $result->fetchAll;

		/*$result = $this->db->query("select count(1) as how_many, sum(port.current_portfolio_num) as how_much
			from $this->reference_schema.verse_ods_kiva_fund_account fa
			left join (select fa.id as fund_account_id,
				count(distinct l.loan_id) as current_portfolio_num
			  	from verse.verse_ods_kiva_fund_account fa
        		inner join verse.verse_ods_kiva_lender_loan_purchase llp on llp.lender_fund_account_id=fa.id

        		inner join verse.verse_dim_loan l on l.loan_id=llp.loan_id and l.status in ('payingBack','raised','fundRaising')
        		group by fa.id) port
        	on port.fund_account_id = fa.id
        	where port.current_portfolio_num is not null");*/
		$result = $this->db->query("select count(1) as how_many, sum(current_portfolio_num) as how_much
			from $this->reference_schema.verse_dim_fund_account
			where current_portfolio_num is not null");
		$from_ods = $result->fetchAll;

		$this->assertEquals($from_ods[0][how_many],$from_vertex[0][how_many]);
		$this->assertEquals($from_ods[0][how_much],$from_vertex[0][how_much]);
	}

	public function testECurrentPortfolioOutstanding() {
		$result = $this->db->query("select count(1) as how_many, sum(e_current_portfolio_outstanding) as how_much
			from $this->vertex_schema.vertex_dim_fund_account_accounts
			where e_current_portfolio_outstanding is not null");
		$from_vertex = $result->fetchAll;

		$result = $this->db->query("select count(1) as how_many, sum(e_current_portfolio_outstanding) as how_much
			from $this->reference_schema.verse_dim_fund_account
			where e_current_portfolio_outstanding is not null");
		$from_ods = $result->fetchAll;

		$this->assertEquals($from_ods[0][how_many],$from_vertex[0][how_many]);
		$this->assertEquals($from_ods[0][how_much],$from_vertex[0][how_much]);
	}

}