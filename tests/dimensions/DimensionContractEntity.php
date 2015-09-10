<?php
class DimensionContractEntityTest extends Kiva\Vertex\Testing\VertexTestCase {

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_contract_entity");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_dim_contract_entity");
		$count_from_kiva_ods = $result->fetchColumn();

		$this->assertEquals($count_from_kiva_ods,$count_from_vertex);
	}

	public function testSourceOfFunds() {
		$result = $this->db->query("select count(*) from $this->vertex_schema.vertex_dim_contract_entity where src_of_funds_id is null");
		$this->assertEquals((int)$result->fetchColumn(), 0);
	}

	public function testNames() {
		$result = $this->db->query("select count(*) from $this->vertex_schema.vertex_dim_contract_entity where name is null");
		$this->assertEquals((int)$result->fetchColumn(), 0);
	}

}