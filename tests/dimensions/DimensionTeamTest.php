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

	/**
	 * There were 3000+ rows in the ods at time of writing.  Let's make sure at least this many rows end up in the table going forward, even if we can't compare to the verse.
	 */
	public function testThereAreRows() {
		$result = $this->db->query("select count(*) from $this->vertex_schema.vertex_dim_team");
		$this->assertGreaterThan(3000, (int) $result->fetchColumn());
	}
}