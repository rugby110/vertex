<?php

class DimensionManagedAccountTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_managed_account");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_managed_account");
		$count_from_ods = $result->fetchColumn();

		//echo "count from vertex: " . $count_from_vertex . " count from ods: $count_from_ods\n";

		//NYSE adds extra record to dim
		$this->assertWithinMargin($count_from_vertex, $count_from_ods, 2);
	}

	public function testRandomSample() {

		$random_ids = $this->_setupHelper();
		//echo $random_ids . "\n";

		$result = $this->db->query("select fund_account_id, managed_account_id, contract_entity_id, accounting_category, promo_fund_id, promo_group_id
			from $this->vertex_schema.vertex_dim_managed_account
			where fund_account_id in ($random_ids)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, managed_account_id, contract_entity_id, accounting_category, promo_fund_id, promo_group_id
			from $this->reference_schema.verse_dim_managed_account
			where fund_account_id in ($random_ids)
			order by fund_account_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);

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

	private function _setupHelper() {
		$random_result = $this->db->query("SELECT fund_account_id
			FROM
     		(SELECT fund_account_id
            , RANDOM() AS RandomNumber
     		FROM $this->reference_schema.verse_ods_kiva_managed_account
     		WHERE RANDOMINT((SELECT COUNT(*) FROM $this->reference_schema.verse_ods_kiva_managed_account ))%100 = 42
     		) AS T1
			ORDER BY RandomNumber
			LIMIT 5");
		$random_ids = $random_result->fetchAll();

		for ($i = 0, $len = count($random_ids); $i < $len; $i++) {
			$id_array[] = $random_ids[$i]['fund_account_id'];
		}

		$id_list = implode(",",$id_array);

		return $id_list;
	}
}