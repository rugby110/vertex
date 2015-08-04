<?php

class DimensionCreditChangeTypeTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_credit_change_type");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_credit_change_type");
		$count_from_kiva_ods = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_zip_credit_change_type");
		$count_from_zip_ods = $result->fetchColumn();

		$this->assertEquals($count_from_kiva_ods + $count_from_zip_ods,$count_from_vertex);
	}

	public function testAllCreditChangeTypesHaveAReportingGroup() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_credit_change_type where reporting_group is null");
		$null_group_count = $result->fetchColumn();

		$this->assertEquals(0, $null_group_count);
	}

}


