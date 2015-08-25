<?php

class DimensionLoanTest extends Kiva\Vertex\Testing\VertexTestCase
{
	public function setUp()
	{
		parent::setUp();
	}

	public function tearDown()
	{
		parent::tearDown();
	}

	public function testTotalCount()
	{
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_loan");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_loan");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods, $count_from_vertex);
	}

}