<?php

/*
 * Unclear how to really test the details of this, so basically just check that the view works.
 */
class DimensionWWWReferrerTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_www_referrer");
		$count_from_vertex = $result->fetchColumn();
		
		$this->assertGreaterThan(800000,$count_from_vertex);
	}
}