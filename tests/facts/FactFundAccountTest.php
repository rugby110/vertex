<?php

class FactFundAccountTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testLoanPurchaseTotalCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_fund_account
			where loan_purchase_total > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_fund_account
			where loan_purchase_total > 0");
		$count_from_dim = $result->fetchColumn();

		$this->assertSame($count_from_dim,$count_from_vertex);
	}

	public function testFundpoolMatchTotalCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_fund_account
			where fundpool_match_total > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_fund_account
			where fundpool_match_total > 0");
		$count_from_dim = $result->fetchColumn();

		//868 fund_account_ids do not have fundpool_match credit changes in ods_kiva_credit_change table
		$this->assertWithinMargin($count_from_dim,$count_from_vertex, 869);
	}

	public function testSample() {
		$result = $this->db->query("select fund_account_id, fundpool_match_total, kivapool_match_total, loan_purchase_total, loan_purchase_num, loan_purchase_auto_total, loan_repayment_total, fundpool_repayment_total, kivapool_repayment_total, loan_refund_total, loan_expired_total, loan_repayment_currency_loss_total, loan_default_total, loan_default_num, withdrawal_sent_num, withdrawal_num, donation_num, deposit_num, cc_user_num
			from $this->vertex_schema.vertex_fact_fund_account
			where fund_account_id in (2163148,1179814,40797,1446652,206331,2166792,1566823,748382,1201668,289732)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, fundpool_match_total, kivapool_match_total, loan_purchase_total, loan_purchase_num, loan_purchase_auto_total, loan_repayment_total, fundpool_repayment_total, kivapool_repayment_total, loan_refund_total, loan_expired_total, loan_repayment_currency_loss_total, loan_default_total, loan_default_num, withdrawal_sent_num, withdrawal_num, donation_num, deposit_num, cc_user_num
			from $this->reference_schema.verse_dim_fund_account
			where fund_account_id in (2163148,1179814,40797,1446652,206331,2166792,1566823,748382,1201668,289732)
			order by fund_account_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);

	}
}
