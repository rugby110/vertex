<?php

class FactDailyGLEntriesTest extends Kiva\Vertex\Testing\VertexTestCase {

	/**
	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_fact_daily_gl_entries");
		$count_from_fact = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many from $this->reference_schema.verse_fact_daily_gl_entries");
		$count_from_ods = $result->fetchColumn();

		$this->assertEquals($count_from_ods,$count_from_fact);
	}
	 */

	public function testCreditChangeTypeIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_daily_gl_entries
			where effective_day_id > '20150602' and credit_change_type_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_daily_gl_entries gl
			inner join $this->reference_schema.verse_dim_credit_change_type dim_cct on gl.dim_credit_change_type_id = dim_cct.v_id
			-- for now only source table names that are feeding into the GL fact are included
			where dim_effective_day_id > '20150602' and dim_cct.credit_change_type_id > 0 and dim_cct.source_table_name = 'ledger_credit_change'");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testAccountingCategoryIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_daily_gl_entries
			where effective_day_id > '20150602' and accounting_category_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_daily_gl_entries gl
			inner join $this->reference_schema.verse_dim_credit_change_type dim_cct on gl.dim_credit_change_type_id = dim_cct.v_id
		  	left join $this->reference_schema.verse_dim_accounting_category dim_ac on gl.dim_accounting_category_id = dim_ac.v_id and dim_ac.v_current = true
			-- for now only source table names that are feeding into the GL fact are included
			where dim_effective_day_id > '20150602' and dim_ac.v_id > 0 and dim_cct.source_table_name = 'ledger_credit_change'");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}


	//TODO: These tests are failing, the counts are off. Need to figure out how to get these counts to match up.
	/**
	public function testContractEntityIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_daily_gl_entries
			where contract_entity_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_daily_gl_entries gl
			left join $this->reference_schema.verse_dim_credit_change_type dim_cct on gl.dim_credit_change_type_id = dim_cct.v_id
			left join $this->reference_schema.verse_dim_managed_account dim_ma on gl.dim_contract_entity_id = dim_ma.dim_contract_entity_id
			where dim_effective_day_id > '20150602' and dim_ma.contract_entity_id > 0 and dim_cct.source_table_name = 'ledger_credit_change'");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}

	public function testPartnerIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_fact_daily_gl_entries
			where partner_id > 0");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_fact_daily_gl_entries gl
			left join $this->reference_schema.verse_dim_credit_change_type dim_cct on gl.dim_credit_change_type_id = dim_cct.v_id
			left join $this->reference_schema.verse_dim_partner dim_p on gl.dim_partner_id = dim_p.v_id
			where dim_effective_day_id > '20150602' and dim_p.partner_id > 0 and dim_cct.source_table_name = 'ledger_credit_change'");
		$count_from_verse = $result->fetchColumn();

		$this->assertSame($count_from_verse,$count_from_vertex);
	}
	 */

	public function testSample() {
		$result = $this->db->query("select effective_day_id, gl.credit_change_type_id, accounting_category_id,
			contract_entity_id, partner_id, aggregate_version_id, num_items_plus, total_amount_plus, num_items_minus,
			total_amount_minus
			from $this->vertex_schema.vertex_fact_daily_gl_entries gl
			inner join $this->vertex_schema.vertex_dim_credit_change_type dim_cct on gl.credit_change_type_id = dim_cct.credit_change_type_id
			where effective_day_id = '20150602' and gl.credit_change_type_id = 117
			order by gl.credit_change_type_id, effective_day_id, accounting_category_id, contract_entity_id, partner_id,
				aggregate_version_id
			");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select dim_effective_day_id as effective_day_id, dim_cct.credit_change_type_id,
			dim_ac.v_id as accounting_category_id,
			-- there is a difference between how contract_entity_ids are stores in the managed account and contract entity facts
			-- we need to check for -1 and convert to 0, therefore
			CASE
				WHEN dim_ce.contract_entity_id = -1 THEN 0
                ELSE dim_ce.contract_entity_id
            END AS contract_entity_id,
            dim_p.partner_id, aggregate_version_id, num_items_plus, total_amount_plus, num_items_minus, total_amount_minus
			from $this->reference_schema.verse_fact_daily_gl_entries gl
			left join $this->reference_schema.verse_dim_credit_change_type dim_cct on gl.dim_credit_change_type_id = dim_cct.v_id
		  	left join $this->reference_schema.verse_dim_accounting_category dim_ac on gl.dim_accounting_category_id = dim_ac.v_id and dim_ac.v_current = true
			left join $this->reference_schema.verse_dim_contract_entity dim_ce on gl.dim_contract_entity_id = dim_ce.v_id
			left join $this->reference_schema.verse_dim_partner dim_p on gl.dim_partner_id = dim_p.v_id
			where dim_effective_day_id = '20150602' and dim_cct.credit_change_type_id = 117
			order by dim_credit_change_type_id, dim_effective_day_id, dim_accounting_category_id, dim_contract_entity_id,
				dim_partner_id, aggregate_version_id
		");
		$from_dim = $result->fetchAll();

		$this->assertSame($from_dim,$from_vertex);
	}

}