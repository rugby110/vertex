<?php

class DimensionFundAccountLedgerFirstDayIdsTest extends Kiva\Vertex\Testing\VertexTestCase
{
	public function setUp()
	{
		parent::setUp();
	}

	public function tearDown()
	{
		parent::tearDown();
	}

	public function testLoanDefaultFirstDayIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_fund_account_ledger_first_day_ids
			where loan_default_first_day_id is not null");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_fund_account
			where loan_default_first_day_id is not null");
		$count_from_dim = $result->fetchColumn();

		$this->assertSame($count_from_dim,$count_from_vertex);
	}


	public function testSample() {
		$result = $this->db->query("select fund_account_id, loan_default_first_day_id, loan_default_last_day_id, withdrawal_sent_first_day_id, withdrawal_sent_last_day_id, promo_loan_default_first_day_id, promo_loan_default_last_day_id
			from $this->vertex_schema.vertex_dim_fund_account_ledger_first_day_ids
			where fund_account_id in (83184,646280,1132469,44527,546786,310390,891449,136869,848656, 268208)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, loan_default_first_day_id, loan_default_last_day_id, withdrawal_sent_first_day_id, withdrawal_sent_last_day_id, promo_loan_default_first_day_id, promo_loan_default_last_day_id
			from $this->reference_schema.verse_dim_fund_account
			where fund_account_id in (83184,646280,1132469,44527,546786,310390,891449,136869,848656, 268208)
			order by fund_account_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}
}