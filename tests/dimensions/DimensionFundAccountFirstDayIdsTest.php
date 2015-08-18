<?php

class DimensionFundAccountFirstDayIdsTest extends Kiva\Vertex\Testing\VertexTestCase
{
	public function setUp()
	{
		parent::setUp();
	}

	public function tearDown()
	{
		parent::tearDown();
	}

	public function testLoanPurchaseFirstDayIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_fund_account_first_day_ids
			where loan_purchase_first_day_id is not null");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_fund_account
			where loan_purchase_first_day_id is not null");
		$count_from_dim = $result->fetchColumn();

		//echo "count from vertex: " . $count_from_vertex . " count from dim: $count_from_dim\n";
		//fund account 865 does not have loan_purchase_first_day_id calculated in dim
		$this->assertWithinMargin($count_from_dim,$count_from_vertex, 2);
	}


	public function testSample() {
		$result = $this->db->query("select fund_account_id, loan_purchase_first_day_id, loan_expired_last_day_id, gift_purchase_first_day_id, donation_last_day_id, withdrawal_first_day_id, deposit_first_day_id, misc_first_day_id, cc_all_first_day_id, cc_user_first_day_id, fundpool_match_last_day_id, uncategorized_last_day_id
			from $this->vertex_schema.vertex_dim_fund_account_first_day_ids
			where fund_account_id in (1592792,1258596,1318273,1768869,757892,61316,1706306,458732,133040,1456554)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();

		$result = $this->db->query("select fund_account_id, loan_purchase_first_day_id, loan_expired_last_day_id, gift_purchase_first_day_id, donation_last_day_id, withdrawal_first_day_id, deposit_first_day_id, misc_first_day_id, cc_all_first_day_id, cc_user_first_day_id, fundpool_match_last_day_id, uncategorized_last_day_id
			from $this->reference_schema.verse_dim_fund_account
			where fund_account_id in (1592792,1258596,1318273,1768869,757892,61316,1706306,458732,133040,1456554)
			order by fund_account_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}
}