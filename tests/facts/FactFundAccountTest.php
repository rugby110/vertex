<?php

class FactFundAccountTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}


	public function testRandomSample() {

		$random_ids = $this->_setupHelper();
		//echo $random_ids . "\n";

		$result = $this->db->query("select fund_account_id, fundpool_match_total, kivapool_match_total, loan_purchase_total, loan_purchase_auto_total, loan_repayment_total, fundpool_repayment_total, kivapool_repayment_total, loan_refund_total, loan_expired_total
			from $this->vertex_schema.vertex_fact_fund_account
			where fund_account_id in ($random_ids)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, fundpool_match_total, kivapool_match_total, loan_purchase_total, loan_purchase_auto_total, loan_repayment_total, fundpool_repayment_total, kivapool_repayment_total, loan_refund_total, loan_expired_total
			from $this->reference_schema.verse_dim_fund_account
			where fund_account_id in ($random_ids)
			order by fund_account_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);

	}


	private function _setupHelper() {
		$random_result = $this->db->query("SELECT fund_account_id
			FROM
     		(SELECT fund_account_id
            , RANDOM() AS RandomNumber
     		FROM $this->vertex_schema.vertex_fact_fund_account
     		WHERE RANDOMINT((SELECT COUNT(*) FROM $this->vertex_schema.vertex_fact_fund_account ))%100 = 42
     		) AS T1
			ORDER BY RandomNumber
			LIMIT 10");
		$random_ids = $random_result->fetchAll();

		for ($i = 0, $len = count($random_ids); $i < $len; $i++) {
			$id_array[] = $random_ids[$i]['fund_account_id'];
		}

		$id_list = implode(",",$id_array);

		return $id_list;
	}
}
