<?php

class FactZipBorrowerCreditChangeTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_fact_zip_borrower_credit_change");
		$count_from_fact = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_fact_zip_borrower_credit_change");
		$count_from_ods = $result->fetchColumn();

		//echo "count from fact: " . $count_from_fact . " count from ods: $count_from_ods\n";
		$this->assertEquals($count_from_ods,$count_from_fact);
	}

	public function testCreditChangeTypeIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_zip_borrower_credit_change
			where credit_change_type_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_zip_borrower_credit_change
			where dim_credit_change_type_id  > 0");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testAccountingCategoryIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_zip_borrower_credit_change
			where accounting_category_id > 0 and accounting_category_id is not NULL");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_zip_borrower_credit_change
			where dim_accounting_category_id > 0 and dim_accounting_category_id is not NULL");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testSample() {
		$result = $this->db->query("select zip_credit_change_id,trans_id,fund_account_id,local_price,usd_price,
 	 		create_time,create_day_id,effective_time,effective_day_id,item_id,ref_id,fx_rate_id,
  			changer_id,changer_type,new_balance,currency,country_id,credit_change_type_id,accounting_category_id
			from $this->vertex_schema.vertex_fact_zip_borrower_credit_change
			where zip_credit_change_id in (930,935,936,939,1286,1288,1525,1526,1714,2103)
			order by zip_credit_change_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select bcc.zip_credit_change_id,bcc.trans_id,bcc.fund_account_id,bcc.local_price,
			bcc.usd_price,bcc.create_time,bcc.create_day_id,bcc.effective_time,bcc.effective_day_id,bcc.item_id,bcc.ref_id,
			bcc.fx_rate_id,bcc.changer_id,bcc.changer_type,bcc.new_balance,bcc.currency,bcc.country_id,
			cct.credit_change_type_id,ac.v_id as accounting_category_id
			from $this->reference_schema.verse_fact_zip_borrower_credit_change bcc
			left join $this->reference_schema.verse_dim_credit_change_type cct on bcc.dim_credit_change_type_id = cct.v_id and cct.v_current = true
			left join $this->reference_schema.verse_dim_accounting_category ac on bcc.dim_accounting_category_id = ac.v_id and ac.v_current = true
			where zip_credit_change_id in (930,935,936,939,1286,1288,1525,1526,1714,2103)
			order by zip_credit_change_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

}