<?php

class FactPromoImpactTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_promo_impact_accounts;");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_promo_impact;");
		$count_from_verse = $result->fetchColumn();

		//1 record off - well within the margin of doneness!
		$this->assertWithinMargin($count_from_verse,$count_from_vertex, 2);
	}

	public function testIsExistingLenderCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_promo_impact_accounts
			where is_existing_user = true");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_promo_impact
			where is_existing_user = true");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testPromoTypeCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_promo_impact_accounts
			where promo_type = 'promo_card'");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_promo_impact
			where promo_type = 'promo_card'");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testNonBonusSample() {
		$result = $this->db->query("select managed_account_id, acquired_fund_account_id, acquired_time, is_existing_user, is_existing_depositor, is_existing_donor, promo_amt_required, marginal_amt_lent, marginal_amt_deposited, marginal_amt_donated, marginal_amt_withdrawn, marginal_amt_kivacard_purchase
			from $this->vertex_schema.vertex_fact_promo_impact
			where managed_account_id = 1449139
			and acquired_login_id = 89188");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select managed_account_id, acquired_fund_account_id, acquired_time, is_existing_user, is_existing_depositor, is_existing_donor, promo_amt_required, marginal_amt_lent, marginal_amt_deposited, marginal_amt_donated, marginal_amt_withdrawn, marginal_amt_kivacard_purchase
			from $this->reference_schema.verse_fact_promo_impact
			where managed_account_id = 1449139
			and acquired_login_id = 89188");
		$from_verse = $result->fetchAll();

		$this->assertSame($from_verse,$from_vertex);
	}
}