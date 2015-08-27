<?php

class FactLedgerCreditChangeTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_fact_ledger_credit_change");
		$count_from_fact = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_ods_kiva_ledger_credit_change");
		$count_from_ods = $result->fetchColumn();

		//echo "count from fact: " . $count_from_fact . " count from ods: $count_from_ods\n";
		$this->assertEquals($count_from_ods,$count_from_fact);
	}

	public function testAccountingCategoryIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_ledger_credit_change
			where accounting_category_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_ledger_credit_change
			where dim_accounting_category_id > 0");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}


	public function testSample() {
		$result = $this->db->query("select ledger_credit_change_id, fund_account_id, create_day_id, effective_day_id
			from $this->vertex_schema.vertex_fact_ledger_credit_change
			where ledger_credit_change_id in (2936352,2612284,2836570,3263171,3033338,3167700,2356817,4764804,4124803,3402161)
			order by ledger_credit_change_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select ledger_credit_change_id, fund_account_id, create_day_id, effective_day_id
			from $this->reference_schema.verse_fact_ledger_credit_change
			where ledger_credit_change_id in (2936352,2612284,2836570,3263171,3033338,3167700,2356817,4764804,4124803,3402161)
			order by ledger_credit_change_id");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

}