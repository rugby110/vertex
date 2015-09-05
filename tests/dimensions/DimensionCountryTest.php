<?php

class DimensionCountryTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_country");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_country");
		$count_from_kiva_ods = $result->fetchColumn();

		$this->assertEquals($count_from_kiva_ods,$count_from_vertex);
	}

	public function testSampleEntry() {
		$result = $this->db->query("select * from " . $this->vertex_schema . ".vertex_dim_country where name = 'Brazil'");
		$row= $result->fetch(PDO::FETCH_ASSOC);

		$this->assertEquals("South America",$row['irs_region']);
		$this->assertEquals("BRA",$row['country_code']);
	}
}