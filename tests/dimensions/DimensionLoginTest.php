<?php

class DimensionLoginTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_login");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_login");
		$count_from_ods = $result->fetchColumn();

		//echo "count from vertex: " . $count_from_vertex . " count from ods: $count_from_ods\n";

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testIsCorporate() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_login
			where is_corporate=true");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_login
			where username like 'KivaCorporateUser%'");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testCommunicationsSettings() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_login
			where sendKivaNews='yes'");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_ods_kiva_login l
			left join verse.verse_ods_kiva_communication_settings com on com.login_id = l.id
			where com.sendKivaNews='yes'");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}
	/*
	 from verse.verse_ods_kiva_login l
	 left join verse.verse_ods_kiva_communication_settings com on com.login_id = l.id
	 */

}


