<?php

class FactPartnerCreditChangeTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_fact_partner_credit_change");
		$count_from_fact = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_fact_partner_credit_change");
		$count_from_ods = $result->fetchColumn();

		//echo "count from fact: " . $count_from_fact . " count from ods: $count_from_ods\n";
		$this->assertEquals($count_from_ods,$count_from_fact);
	}

	public function testCreditChangeTypeIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_partner_credit_change
			where credit_change_type_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_partner_credit_change
			where dim_credit_change_type_id  > 0");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testSample() {
		$result = $this->db->query("select partner_credit_change_id,price,ref_id,admin_user_id,create_time,
			create_day_id,effective_time,effective_day_id,statement_id
			from $this->vertex_schema.vertex_fact_partner_credit_change
			where partner_credit_change_id in (12,35,22242,48804,93519,103801,382658,407193,1404138,1567711)
			order by partner_credit_change_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select partner_credit_change_id,price,ref_id,admin_user_id,create_time,
			create_day_id,effective_time,effective_day_id,statement_id
			from $this->reference_schema.verse_fact_partner_credit_change
			where partner_credit_change_id in (12,35,22242,48804,93519,103801,382658,407193,1404138,1567711)
			order by partner_credit_change_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

}