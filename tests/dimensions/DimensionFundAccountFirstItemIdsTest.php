<?php

class DimensionFundAccountFirstItemIdsTest extends Kiva\Vertex\Testing\VertexTestCase
{
	public function setUp()
	{
		parent::setUp();
	}

	public function tearDown()
	{
		parent::tearDown();
	}

	public function testFundpoolMatchFirstItemIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_fund_account_first_item_ids
			where fundpool_match_first_item_id is not null");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_fund_account
			where fundpool_match_first_item_id is not null");
		$count_from_dim = $result->fetchColumn();

		//echo "count from vertex: " . $count_from_vertex . " count from dim: $count_from_dim\n";
		//discrepancy of 314 - fund_accounts with fundpool_match credit changes but no item_id calculated in dim
		$this->assertWithinMargin($count_from_dim,$count_from_vertex, 315);
	}

	public function testKivapoolMatchFirstItemIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_fund_account_first_item_ids
			where kivapool_match_first_item_id is not null");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_fund_account
			where kivapool_match_first_item_id is not null");
		$count_from_dim = $result->fetchColumn();

		$this->assertEquals($count_from_dim,$count_from_vertex);
	}

	public function testSample() {
		$result = $this->db->query("select fund_account_id, fundpool_match_first_item_id, kivapool_match_first_item_id
			from $this->vertex_schema.vertex_dim_fund_account_first_item_ids
			where fund_account_id in (1490199,588273,2166474,1232711,1451420,1213911,1167365,1633681,1733237,735000)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();

		$result = $this->db->query("select fund_account_id, fundpool_match_first_item_id, kivapool_match_first_item_id
			from $this->reference_schema.verse_dim_fund_account
			where fund_account_id in (1490199,588273,2166474,1232711,1451420,1213911,1167365,1633681,1733237,735000)
			order by fund_account_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}
}