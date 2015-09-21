<?php

class FactOperationsCreditChangeTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_fact_operations_credit_change");
		$count_from_fact = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_fact_operations_credit_change");
		$count_from_ods = $result->fetchColumn();

		//echo "count from fact: " . $count_from_fact . " count from ods: $count_from_ods\n";
		$this->assertEquals($count_from_ods,$count_from_fact);
	}

	public function testAdminUserIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_operations_credit_change
			where admin_user_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_operations_credit_change
			where admin_user_id > 0");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testSample() {
		$result = $this->db->query("select operations_credit_change_id,admin_user_id,price,create_time,create_day_id,
			effective_time,effective_day_id,pp_txn_id
			from $this->vertex_schema.vertex_fact_operations_credit_change
			where operations_credit_change_id in (10567, 10678, 10789, 10904, 10342)
			order by operations_credit_change_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select operations_credit_change_id,admin_user_id,price,create_time,create_day_id,
			effective_time,effective_day_id,pp_txn_id
			from $this->reference_schema.verse_fact_operations_credit_change
			where operations_credit_change_id in (10567, 10678, 10789, 10904, 10342)
			order by operations_credit_change_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

}