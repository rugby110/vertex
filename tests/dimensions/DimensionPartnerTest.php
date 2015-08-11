<?php

class DimensionParnterTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_partner");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_partner");
		$count_from_kiva_ods = $result->fetchColumn();

		$this->assertEquals($count_from_kiva_ods,$count_from_vertex);
	}

	public function testRandomSample() {

		$random_ids = $this->_setupHelper();
		echo $random_ids;

		$result = $this->db->query("select partner_id, name, status, first_fundraising_day_id, charges_fees_interest, enable_relisting
			from $this->vertex_schema.vertex_dim_partner
			where partner_id in ($random_ids)
			order by partner_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select partner_id, name, status, first_fundraising_day_id, charges_fees_interest, enable_relisting
			from $this->reference_schema.verse_dim_partner
			where partner_id in ($random_ids)
			order by partner_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);

	}

	private function _setupHelper() {

		$random_result = $this->db->query("SELECT id
			FROM
     		(SELECT id
            , RANDOM() AS RandomNumber
     		FROM $this->reference_schema.verse_ods_kiva_partner
     		WHERE RANDOMINT((SELECT COUNT(*) FROM $this->reference_schema.verse_ods_kiva_partner ))%100 = 42
     		) AS T1
			ORDER BY RandomNumber
			LIMIT 5");
		$random_ids = $random_result->fetchAll();

		for ($i = 0, $len = count($random_ids); $i < $len; $i++) {
			$id_array[] = $random_ids[$i]['id'];
		}

		$id_list = implode(",",$id_array);

		return $id_list;

	}

}