<?php

class FactCreditChangeTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_fact_credit_change");
		$count_from_fact = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_credit_change");
		$count_from_ods = $result->fetchColumn();

		echo "count from fact: " . $count_from_fact . " count from ods: $count_from_ods\n";

		$this->assertEquals($count_from_ods,$count_from_fact);
	}
}


