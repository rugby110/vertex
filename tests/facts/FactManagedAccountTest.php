<?php

class FactManagedAccountTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testPromoAmountRedeemedCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_managed_account
			where promo_redeemed_amt > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_managed_account
			where promo_redeemed_amt > 0");
		$count_from_dim = $result->fetchColumn();

		$this->assertSame($count_from_dim,$count_from_vertex);
	}


	public function testSample() {
		$result = $this->db->query("select fund_account_id, promo_fund_id, promo_redeemed_amt, total_amount_disbursed, total_amount_repaid, total_amount_donated, total_amount_lost, total_amount_refunded, number_loans
			from $this->vertex_schema.vertex_fact_managed_account
			where fund_account_id in (1473428, 1186366, 1731534, 1473411, 1666360, 990719, 807517, 1001501, 2166208, 942885)
			order by fund_account_id, promo_fund_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, promo_fund_id, promo_redeemed_amt, total_amount_disbursed, total_amount_repaid, total_amount_donated, total_amount_lost, total_amount_refunded, number_loans
			from $this->reference_schema.verse_dim_managed_account
			where fund_account_id in (1473428, 1186366, 1731534, 1473411, 1666360, 990719, 807517, 1001501, 2166208, 942885)
			order by fund_account_id, promo_fund_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}
}
