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

	public function testDescriptionWordCountCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_loan
			where description_word_count > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_dim_loan
			where description_word_count > 0");
		$count_from_dim = $result->fetchColumn();

		$this->assertEquals($count_from_dim,$count_from_vertex);
	}

	public function testNumRepaymentExpectedCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_loan
			where num_repayment_expected > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_dim_loan
			where num_repayment_expected > 0");
		$count_from_dim = $result->fetchColumn();

		$this->assertEquals($count_from_dim,$count_from_vertex);
	}

	public function testSpAntiPovertyFocusCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_loan
			where sp_anti_poverty_focus = true");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_dim_loan
			where sp_anti_poverty_focus = true");
		$count_from_dim = $result->fetchColumn();

		$this->assertEquals($count_from_dim,$count_from_vertex);
	}

	public function testRelistingIdCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_loan
			where relisting_id is not null");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_dim_loan
			where dim_relisting_id > 0");
		$count_from_dim = $result->fetchColumn();

		$this->assertEquals($count_from_dim,$count_from_vertex);
	}

	public function testSample() {
		$result = $this->db->query("select loan_id, status, business_id, has_video_profile, create_day_id,
					sp_num_badges, sp_client_voice, loan_theme_type_name, num_entreps, gender, num_journals_total,
					shares_purchased_total, num_repayment_expected, settled_total, currency_loss_lenders_num
			from $this->vertex_schema.vertex_dim_loan
			where loan_id in (714494,463925,249618,599914,838691,906812,127587,90588,845518,658525)
			order by loan_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select loan_id, status, business_id, has_video_profile, create_day_id,
					sp_num_badges, sp_client_voice, loan_theme_type_name, num_entreps, gender, num_journals_total,
					shares_purchased_total, num_repayment_expected, settled_total, currency_loss_lenders_num
			from $this->reference_schema.verse_dim_loan
			where loan_id in (714494,463925,249618,599914,838691,906812,127587,90588,845518,658525)
			order by loan_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

	public function testDafEligible() {
		//ensure 2 possible values
		$val_count = $this->db->query("select distinct daf_eligible from $this->reference_schema.verse_ods_kiva_loan");
		$this->assertSame($val_count->rowCount() , 2); //'yes' and 'no'
		//and, check the counts.
		$ref = $this->db->query("select daf_eligible, count(1) as count from $this->reference_schema.verse_ods_kiva_loan group by daf_eligible order by daf_eligible asc");
		$vertex = $this->db->query("select daf_eligible, count(1) as count from $this->vertex_schema.vertex_dim_loan group by daf_eligible order by daf_eligible asc");
		$this->assertSame($ref->fetchAll(), $vertex->fetchAll());
	}
}