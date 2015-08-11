<?php

class DimensionFundAccountTest extends Kiva\Vertex\Testing\VertexTestCase
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
		$count_from_ods = $result->fetchColumn();

		$this->assertWithinMargin($count_from_ods,$count_from_vertex, 10);

	}


	public function testDayIds() {

		$random_ids = $this->_setupHelper();

		$result = $this->db->query("select fund_account_id, loan_purchase_first_day_id
			from $this->vertex_schema.vertex_dim_fund_account_first_day_ids
			where fund_account_id in ($random_ids)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, loan_purchase_first_day_id
			from $this->reference_schema.verse_dim_fund_account
			where fund_account_id in ($random_ids)
			order by fund_account_id");
		$from_ods = $result->fetchAll();

		$this->assertSame($from_ods,$from_vertex);

	}

	private function _setupHelper() {

		$random_result = $this->db->query("	SELECT fund_account_id
			FROM
     		(SELECT fund_account_id
            , RANDOM() AS RandomNumber
     		FROM $this->reference_schema.verse_dim_fund_account
     		WHERE RANDOMINT((SELECT COUNT(*) FROM $this->reference_schema.verse_dim_fund_account ))%100 = 42
     		and (fundpool_match_first_item_id is not null or kivapool_match_first_item_id is not null)
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

	/**
	 * Asserts that two numbers are within the given margin.
	 *
	 * @param  $a - a number
	 * @param  $b - another number
	 * @param  $margin - the margin $a and $b should be within
	 * @param string $message - error message passed to assertTrue
	 */
	public function assertWithinMargin($a, $b, $margin, $message = '') {
		$this->assertTrue(abs($a - $b) < $margin, $message);
	}
}