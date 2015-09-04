<?php

class FactManagedAccountStatisticsTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	//this tests the same sql logic against itself, only the verse query pulls from old verse facts & dims while vertex pulls against... vertex
	public function testCreditChangeSums() {
		$result = $this->db->query("select sum(purchase_amount) as purchase_amount, sum(deposit_amount) as deposit_amount
           							  from $this->vertex_schema.vertex_fact_managed_account_statistics;");
		$from_vertex = $result->fetchAll();

		$result = $this->db->query("SELECT
            sum(CASE
                WHEN fact_cc.dim_credit_change_type_id IN (49, 69, 64, 152, 42, 24, 71)
                THEN -price
                ELSE 0
            END) AS purchase_amount,

            sum(CASE
                WHEN fact_cc.dim_credit_change_type_id IN (6, 7, 8, 28, 29, 30, 31, 38, 45, 56, 57, 58, 59, 60, 62, 63, 67, 68, 72)
                THEN price
                ELSE 0
            END) AS deposit_amount

			FROM
            $this->reference_schema.verse_fact_credit_change fact_cc
        	INNER JOIN verse.verse_dim_managed_account ma ON fact_cc.fund_account_id = ma.fund_account_id
        	INNER JOIN verse.verse_dim_credit_change_type dimcct ON dimcct.v_id = dim_credit_change_type_id
        	INNER JOIN verse.verse_fact_fund_account fa ON fa.fund_account_id = ma.fund_account_id
        	LEFT JOIN verse.verse_ods_kiva_repayment_settled rs ON rs.id = ref_id
        	LEFT JOIN verse.verse_dim_loan loan ON
            CASE
                WHEN fact_cc.dim_credit_change_type_id IN (64, -- fundpool_match
                                                           69) -- kivapool_match
                THEN ref_id
                WHEN fact_cc.dim_credit_change_type_id in (27,  -- loan_repayment_currency_loss
                                                           65, -- fundpool_repayment
                                                           70) -- kivapool_repayment
                        AND fact_cc.ref_id < 2000000
                THEN ref_id
                WHEN fact_cc.dim_credit_change_type_id = 65 -- fundpool_repayment
                        AND fact_cc.ref_id > 2000000
                THEN rs.loan_id
                WHEN dimcct.item_refers_to = 'business'
                THEN item_id
                WHEN dimcct.ref_refers_to = 'business'
                THEN ref_id
                ELSE NULL
            END = loan.loan_id
        	LEFT JOIN verse.verse_dim_geo geo ON loan.dim_geo_id = geo.v_id
        	WHERE
            fact_cc.fund_account_id > 0;");
		$from_verse = $result->fetchAll();

		$this->assertSame($from_verse,$from_vertex);
	}

	public function testLedgerCreditChangeSums() {
		$result = $this->db->query("select sum(default_amount) as default_amount
           							  from $this->vertex_schema.vertex_fact_managed_account_statistics;");
		$from_vertex = $result->fetchColumn();

		$result = $this->db->query("SELECT
            sum(CASE
                WHEN fact_cc.dim_credit_change_type_id IN (100, 110, 111, 103)
                THEN price
                ELSE 0
            END) AS default_amount

			FROM
            $this->reference_schema.verse_fact_ledger_credit_change fact_cc
        	INNER JOIN $this->reference_schema.verse_dim_managed_account ma ON fact_cc.fund_account_id = ma.fund_account_id
        	INNER JOIN $this->reference_schema.verse_dim_credit_change_type dimcct ON dimcct.v_id = dim_credit_change_type_id
        	INNER JOIN $this->reference_schema.verse_fact_fund_account fa ON fa.fund_account_id = ma.fund_account_id
        	INNER JOIN $this->reference_schema.verse_dim_loan loan ON loan.loan_id = fact_cc.ref_id
        	INNER JOIN $this->reference_schema.verse_dim_geo geo ON loan.dim_geo_id = geo.v_id
        	WHERE fact_cc.fund_account_id > 0;");
		$from_verse = $result->fetchColumn();

		$this->assertSame($from_verse,$from_vertex);
	}
}