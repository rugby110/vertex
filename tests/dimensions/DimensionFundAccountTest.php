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
			from $this->reference_schema.verse_dim_fund_account fa
			where country_id != 0");
		$count_from_dim = $result->fetchColumn();

		//there are 7 recs in dim where country_id = 0, but not through ods table joins
		$this->assertWithinMargin($count_from_dim,$count_from_vertex, 8);
	}

	public function testGeoStateCodesIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_fund_account_accounts
			where geo_state_codes_id != 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_fund_account fa
			where geo_state_codes_id != 0");
		$count_from_dim = $result->fetchColumn();

		//echo "count from vertex: " . $count_from_vertex . " count from dim: $count_from_dim\n";
		//there are 72 recs through table joins where geo_state_codes_id = 0, but not dim
		$this->assertWithinMargin($count_from_dim,$count_from_vertex, 73);
	}

	public function testCurrentPortfolioNum() {
		$result = $this->db->query("select count(1) as how_many, sum(current_portfolio_num) as how_much
			from $this->vertex_schema.vertex_dim_fund_account_accounts
			where current_portfolio_num is not null");
		$from_vertex = $result->fetchAll;

		$result = $this->db->query("select count(1) as how_many, sum(current_portfolio_num) as how_much
			from $this->reference_schema.verse_dim_fund_account
			where current_portfolio_num is not null");
		$from_dim = $result->fetchAll;

		$this->assertEquals($from_dim[0][how_many],$from_vertex[0][how_many]);
		$this->assertEquals($from_dim[0][how_much],$from_vertex[0][how_much]);
	}

	public function testECurrentPortfolioOutstanding() {
		$result = $this->db->query("select count(1) as how_many, sum(e_current_portfolio_outstanding) as how_much
			from $this->vertex_schema.vertex_dim_fund_account_accounts
			where e_current_portfolio_outstanding is not null");
		$from_vertex = $result->fetchAll;

		$result = $this->db->query("select count(1) as how_many, sum(e_current_portfolio_outstanding) as how_much
			from $this->reference_schema.verse_dim_fund_account
			where e_current_portfolio_outstanding is not null");
		$from_dim = $result->fetchAll;

		$this->assertEquals($from_dim[0][how_many],$from_vertex[0][how_many]);
		$this->assertEquals($from_dim[0][how_much],$from_vertex[0][how_much]);
	}
}