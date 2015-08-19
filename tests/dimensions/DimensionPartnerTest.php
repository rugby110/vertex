<?php

class DimensionPartnerTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_partner");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_partner");
		$count_from_kiva_ods = $result->fetchColumn();

		$this->assertEquals($count_from_kiva_ods,$count_from_vertex);
	}

	public function testSample() {
		$result = $this->db->query("select partner_id, name, status, first_fundraising_day_id, charges_fees_interest, enable_relisting
			from $this->vertex_schema.vertex_dim_partner
			where partner_id in (322,243,176,182,96,270,220,168,281,451)
			order by partner_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select distinct partner_id, name, status, first_fundraising_day_id, charges_fees_interest, enable_relisting
			from $this->reference_schema.verse_dim_partner
			where partner_id in (322,243,176,182,96,270,220,168,281,451)
			order by partner_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}
}