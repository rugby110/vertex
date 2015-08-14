<?php

class DimensionLoginTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_login");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_login");
		$count_from_ods = $result->fetchColumn();

		//echo "count from vertex: " . $count_from_vertex . " count from ods: $count_from_ods\n";

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testIsCorporateCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_login
			where is_corporate=true");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_login
			where username like 'KivaCorporateUser%'");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testCommunicationsSettingsCount() {
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

	public function testFacebookEntry() {
		$result = $this->db->query("select facebook_connect_status as status
			from $this->vertex_schema.vertex_dim_login
			where id = 250");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select status as status
			from $this->reference_schema.verse_ods_kiva_facebook_user l
			where user_id=250");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_vertex);
	}

	public function testInviteeCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_login
			where inviter_login_id is not null");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_ods_kiva_login l
			inner join verse.verse_ods_kiva_invitation inv on inv.invitee_id = l.id
			where inviter_id is not null
			");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_vertex);
		$this->assertGreaterThan(700000, $count_from_vertex);
	}

	public function testKivaCardRedeemerCount() {
		$result = $this->db->query("select count(*) as how_many
			from $this->vertex_schema.vertex_dim_login
			where
			first_item_category = 'Kiva Card Redeemer' and
			registration_day_id <= 20150101");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(*) as how_many
			from $this->reference_schema.verse_dim_login
			where
			first_item_category = 'Kiva Card Redeemer' and
			registration_day_id <= 20150101");
		$count_from_verse = $result->fetchColumn();

		// the verse seems to be missing some data, so make sure we have as many or more rows
		$this->assertGreaterThanOrEqual($count_from_verse, $count_from_vertex);
	}
}


