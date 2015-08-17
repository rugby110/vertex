<?php

class FactManagedAccountTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}


	public function testRandomSample() {

		$random_ids = $this->_setupHelper();
		//echo $random_ids . "\n";

		$result = $this->db->query("select fund_account_id, promo_fund_id, promo_redeemed_amt, total_amount_disbursed, total_amount_repaid, total_amount_donated, total_amount_lost, total_amount_refunded, number_loans
			from $this->vertex_schema.vertex_fact_managed_account
			where fund_account_id in ($random_ids)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, promo_fund_id, promo_redeemed_amt, total_amount_disbursed, total_amount_repaid, total_amount_donated, total_amount_lost, total_amount_refunded, number_loans
			from $this->reference_schema.verse_dim_managed_account
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
     		FROM $this->vertex_schema.vertex_fact_managed_account
     		WHERE RANDOMINT((SELECT COUNT(*) FROM $this->vertex_schema.vertex_fact_managed_account ))%100 = 42
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
