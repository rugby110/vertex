<?php

class FactZipCreditChangeTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_fact_zip_credit_change");
		$count_from_fact = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_fact_zip_credit_change");
		$count_from_ods = $result->fetchColumn();

		//echo "count from fact: " . $count_from_fact . " count from ods: $count_from_ods\n";
		$this->assertEquals($count_from_ods,$count_from_fact);
	}

	public function testCreditChangeTypeIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_zip_credit_change
			where credit_change_type_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_zip_credit_change
			where dim_credit_change_type_id  > 0");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testAccountingCategoryIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_zip_credit_change
			where accounting_category_id > 0 and create_time < 1435660549");	//the create_time filter is to get around the fact that Zip CC ODS and fact tables were slightly out of sync when snapshot was made
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_zip_credit_change
			where dim_accounting_category_id > 0 and create_time < 1435660549");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testSample() {
		$result = $this->db->query("select zip_credit_change_id,trans_id,fund_account_id,price,create_time,create_day_id,
  			effective_time,effective_day_id,item_id,ref_id,changer_id,changer_type,new_balance,currency,fx_rate_id,
  			credit_change_type_id, accounting_category_id
			from $this->vertex_schema.vertex_fact_zip_credit_change
			where zip_credit_change_id in (8300491,8300492,8300494,8300495,8300501,8300502,8300505,8300506,8300510,8300512)
			order by zip_credit_change_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select cc.zip_credit_change_id,cc.trans_id,cc.fund_account_id,cc.price,cc.create_time,
			cc.create_day_id,cc.effective_time,cc.effective_day_id,cc.item_id,cc.ref_id,cc.changer_id,cc.changer_type,
			cc.new_balance,cc.currency,cc.fx_rate_id,cct.credit_change_type_id,ac.v_id as accounting_category_id
			from $this->reference_schema.verse_fact_zip_credit_change cc
			left join $this->reference_schema.verse_dim_credit_change_type cct on cc.dim_credit_change_type_id = cct.v_id and cct.v_current = true
			left join $this->reference_schema.verse_dim_accounting_category ac on cc.dim_accounting_category_id = ac.v_id and ac.v_current = true
			where zip_credit_change_id in (8300491,8300492,8300494,8300495,8300501,8300502,8300505,8300506,8300510,8300512)
			order by zip_credit_change_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

}