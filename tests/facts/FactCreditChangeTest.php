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

		//echo "count from fact: " . $count_from_fact . " count from ods: $count_from_ods\n";

		$this->assertEquals($count_from_ods,$count_from_fact);
	}

	public function testPrice() {
		$result = $this->db->query("select sum(price) as how_much from $this->vertex_schema.vertex_fact_credit_change");
		$sum_from_fact = $result->fetchColumn();

		$result = $this->db->query("select sum(price) as how_much from $this->reference_schema.verse_ods_kiva_credit_change");
		$sum_from_ods = $result->fetchColumn();

		$this->assertEquals($sum_from_ods,$sum_from_fact);
	}

	public function testUserAccountTypeCount() {
		$result = $this->db->query("select count(1) as how_much from $this->vertex_schema.vertex_fact_credit_change
									where user_account_type > 0;");
		$count_from_fact = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_much from $this->reference_schema.verse_fact_credit_change
									where user_account_type > 0;");
		$count_from_dim = $result->fetchColumn();

		$this->assertEquals($count_from_dim,$count_from_fact);
	}

	public function testSample() {
		$result = $this->db->query("select credit_change_id, trans_id, changer_id, changer_type, effective_day_id, user_account_type
			from $this->vertex_schema.vertex_fact_credit_change
			where credit_change_id in (94036216, 58567425, 44838499, 128920733, 60443118, 105222111, 144529686, 162360930, 132458036, 183434305)
			order by credit_change_id");
		$from_vertex = $result->fetchAll();

		$result = $this->db->query("select credit_change_id, trans_id, changer_id, changer_type, effective_day_id, user_account_type
			from $this->reference_schema.verse_fact_credit_change
			where credit_change_id in (94036216, 58567425, 44838499, 128920733, 60443118, 105222111, 144529686, 162360930, 132458036, 183434305)
			order by credit_change_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}
}


