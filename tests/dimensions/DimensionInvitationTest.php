<?php

class DimensionInvitationTest extends Kiva\Vertex\Testing\VertexTestCase {

	public function setUp()
	{
		parent::setUp();
	}

	public function tearDown()
	{
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_invitation");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_invitation");
		$count_from_kiva_ods = $result->fetchColumn();

		$this->assertEquals($count_from_kiva_ods,$count_from_vertex);
	}

	public function testTeamCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_invitation
									where team_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_dim_invitation
									where dim_team_id > 0");
		$count_from_verse = $result->fetchColumn();

		//verse invitation_ids (772108, 772448, 772243, 556007) are missing dim_team_id, though they exist in ods table
		$this->assertEquals($count_from_verse+4,$count_from_vertex);
	}

	public function testDaysToConfirmCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_invitation
									where days_to_confirm > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_dim_invitation
									where days_to_confirm > 0");
		$count_from_verse = $result->fetchColumn();


		$this->assertEquals($count_from_verse,$count_from_vertex);
	}

	public function testSample() {
		$result = $this->db->query("select invitation_id, date_sent_day_id, created_as_type, source, days_to_confirm
			from $this->vertex_schema.vertex_dim_invitation
			where invitation_id in (801797, 821577, 473617, 605505, 189011, 782401, 753987, 642078, 175909, 430059)
			order by invitation_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select invitation_id, date_sent_day_id, created_as_type, source, days_to_confirm
			from $this->reference_schema.verse_dim_invitation
			where invitation_id in (801797, 821577, 473617, 605505, 189011, 782401, 753987, 642078, 175909, 430059)
			order by invitation_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

}