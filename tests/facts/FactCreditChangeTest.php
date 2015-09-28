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

	public function testSample() {
		$result = $this->db->query("select credit_change_id,trans_id,fund_account_id,changer_id,changer_type,credit_change_type_id,
			price,create_time,create_day_id,effective_time,effective_day_id,item_id,ref_id,new_balance,
			accounting_category_id
			from $this->vertex_schema.vertex_fact_credit_change
			where credit_change_id in (94036216, 58567425, 44838499, 128920733, 60443118, 105222111, 144529686, 162360930, 132458036, 183434305)
			order by credit_change_id");
		$from_vertex = $result->fetchAll();

		$result = $this->db->query("select cc.credit_change_id,cc.trans_id,cc.fund_account_id,cc.changer_id,cc.changer_type,
			cct.credit_change_type_id,cc.price,cc.create_time,cc.create_day_id,cc.effective_time,cc.effective_day_id,
			cc.item_id,cc.ref_id,cc.new_balance,ac.v_id as accounting_category_id
			from $this->reference_schema.verse_fact_credit_change cc
			left join $this->reference_schema.verse_dim_credit_change_type cct on cc.dim_credit_change_type_id = cct.v_id and cct.v_current = true
			left join $this->reference_schema.verse_dim_accounting_category ac on cc.dim_accounting_category_id = ac.v_id and ac.v_current = true
			where credit_change_id in (94036216, 58567425, 44838499, 128920733, 60443118, 105222111, 144529686, 162360930, 132458036, 183434305)
			order by credit_change_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

	public function testDescriptions() {
		$result = $this->db->query("select count(distinct description)
			from $this->vertex_schema.vertex_fact_credit_change");
		$count = $result->fetchColumn();

		//the kiva db has 170000+.  Lets just make sure that we're pulling in at least this many.
		$this->assertGreaterThan(170000,$count);
	}
}


