<?php

class DimensionLanguageTest extends Kiva\Vertex\Testing\VertexTestCase {

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_language");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_dim_language");
		$count_from_kiva_ods = $result->fetchColumn();

		//we're filtering out the verse row with id = 0, name = 'None'?
		$this->assertEquals($count_from_kiva_ods-1,$count_from_vertex);
	}

	public function testName() {
		$result = $this->db->query("select count(*) from $this->vertex_schema.vertex_dim_language where name is null OR name = ''");
		$this->assertEquals((int)$result->fetchColumn(), 0);
	}

	public function testIsoCode() {
		$result = $this->db->query("select count(*) from $this->vertex_schema.vertex_dim_language where iso_code is null OR iso_code = ''");
		$this->assertEquals((int)$result->fetchColumn(), 0);
	}

}