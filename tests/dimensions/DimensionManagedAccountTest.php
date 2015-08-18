<?php

class DimensionManagedAccountTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_managed_account");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_managed_account");
		$count_from_ods = $result->fetchColumn();

		//NYSE adds extra record to dim
		$this->assertWithinMargin($count_from_vertex, $count_from_ods, 2);
	}

	public function testSample() {
		$result = $this->db->query("select fund_account_id, managed_account_id, contract_entity_id, accounting_category, promo_fund_id, promo_group_id
			from $this->vertex_schema.vertex_dim_managed_account
			where fund_account_id in (1809636,1473282,1731534,1813492,1473428,1090457)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, managed_account_id, contract_entity_id, accounting_category, promo_fund_id, promo_group_id
			from $this->reference_schema.verse_dim_managed_account
			where fund_account_id in (1809636,1473282,1731534,1813492,1473428,1090457)
			order by fund_account_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}
}