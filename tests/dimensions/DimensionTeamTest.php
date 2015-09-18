<?php

/**
 * Class DimensionTeamTest
 *
 * NOTE we can't do a verse row count comparison, because 1000+ spam team names have been removed from the ODS
 */
class DimensionTeamTest extends Kiva\Vertex\Testing\VertexTestCase {

	public function testNames() {
		$result = $this->db->query("select count(*) from $this->vertex_schema.vertex_dim_team where name is null");
		$this->assertEquals((int)$result->fetchColumn(), 0);
	}

	public function testStatus() {
		$result = $this->db->query("select count(*) from $this->vertex_schema.vertex_dim_team where status is null");
		$this->assertEquals((int)$result->fetchColumn(), 0);
	}

	public function testCategory() {
		$result = $this->db->query("select count(*) from $this->vertex_schema.vertex_dim_team where category is null");
		$this->assertEquals((int)$result->fetchColumn(), 0);
	}
}