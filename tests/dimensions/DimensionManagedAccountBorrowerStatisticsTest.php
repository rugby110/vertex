<?php

class DimensionManagedAccountBorrowerStatisticsTest extends Kiva\Vertex\Testing\VertexTestCase
{
	public function setUp()
	{
		parent::setUp();
	}

	public function tearDown()
	{
		parent::tearDown();
	}

    //this tests the same sql logic against itself, only the verse query pulls from old verse facts & dims while vertex pulls against... vertex
	public function testSums() {
		$result = $this->db->query("select sum(purchase_amount) as purchase_amount
           							  from $this->vertex_schema.vertex_dim_managed_account_borrower_statistics;");
		$from_vertex = $result->fetchColumn();

		$result = $this->db->query("SELECT
            						sum(CASE
                						WHEN fact_cc.dim_credit_change_type_id IN (49, 69, 64, 152, 42, 24, 71)
                                        THEN -price
                						ELSE 0
            						END) AS purchase_amount

			FROM
            $this->reference_schema.verse_fact_credit_change fact_cc
        	INNER JOIN $this->reference_schema.verse_dim_managed_account ma ON fact_cc.fund_account_id = ma.fund_account_id
       		INNER JOIN $this->reference_schema.verse_dim_credit_change_type dimcct ON dimcct.v_id = dim_credit_change_type_id
        	INNER JOIN $this->reference_schema.verse_fact_fund_account fa ON fa.fund_account_id = ma.fund_account_id
        	LEFT JOIN $this->reference_schema.verse_dim_loan loan ON
            CASE
                WHEN fact_cc.dim_credit_change_type_id IN (64, 69)
                THEN ref_id
                WHEN fact_cc.dim_credit_change_type_id = 27
                        AND fact_cc.ref_id < 2000000
                THEN ref_id
                WHEN dimcct.item_refers_to = 'business'
                THEN item_id
                WHEN dimcct.ref_refers_to = 'business'
                THEN ref_id
                ELSE NULL
            END = loan.loan_id
        	LEFT JOIN $this->reference_schema.verse_dim_geo geo ON loan.dim_geo_id = geo.v_id

			WHERE fact_cc.fund_account_id > 0 and loan.loan_id is not null
			and CASE
                WHEN fact_cc.dim_credit_change_type_id IN (49, 69, 64, 152, 42, 24, 71)
                -- ('promo_loan_credit', 'kivapool_match', 'fundpool_match', 'loan_share_recapture', 'm_loan_purchase_void', 'loan_purchase', 'loan_purchase_auto'))

                THEN -price
                ELSE 0
            END > 0;");
		$from_verse = $result->fetchColumn();

		$this->assertSame($from_verse,$from_vertex);
	}
}