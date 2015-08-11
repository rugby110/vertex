<?php

class DimensionFundAccountTest extends Kiva\Vertex\Testing\VertexTestCase
{
	public function setUp()
	{
		parent::setUp();
	}

	public function tearDown()
	{
		parent::tearDown();
	}

	public function testFundpoolMatchFirstItemIdCount() {
		$result = $this->db->query("select count(1) as how_many
			from $this->vertex_schema.vertex_dim_fund_account_first_item_ids
			where fundpool_match_first_item_id is not null");
		$count_from_vertex = $result->fetchColumn();

		$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_dim_fund_account
			where fundpool_match_first_item_id is not null");
		$count_from_ods = $result->fetchColumn();

		$this->assertWithinMargin($count_from_ods,$count_from_vertex, 400);
		//$this->assertEquals($count_from_ods,$count_from_vertex);

	}

	public function testItemIds() {
		//$result = $this->db->query("select count(1) as how_many
		$result = $this->db->query("select fund_account_id, fundpool_match_first_item_id, kivapool_match_first_item_id
			from $this->vertex_schema.vertex_dim_fund_account_first_item_ids
			--where fundpool_match_first_item_id is not null
			-- random sample:
			where fund_account_id in (1351462, 565738, 1352542, 2139244)
			order by fund_account_id
			--and TO_CHAR(TO_TIMESTAMP(create_time), 'YYYYMMDD')::INT < 20150101");
		//$count_from_vertex = $result->fetchColumn();
		$from_vertex = $result->fetchAll();

		/*$result = $this->db->query("select count(1) as how_many
			from $this->reference_schema.verse_ods_kiva_fund_account fa
			left join ( select fund_account_id,
        	max(case when type_name = 'fundpool_match'
            	then item_id end) as fundpool_match_first_item_id,
        	max(case when type_name = 'kivapool_match'
            	then item_id end) as kivapool_match_first_item_id

        	from (

         	select fund_account_id, dim_credit_change_type_id as type_id, cct.type_name, item_id, effective_time, min(effective_time)
         	over (partition by fund_account_id, dim_credit_change_type_id) min_eff_time
         	from vertex_fact_credit_change cc
         	inner join verse.verse_dim_credit_change_type cct on cc.dim_credit_change_type_id = cct.v_id
        	where dim_credit_change_type_id in
                (select v_id
                from verse.verse_dim_credit_change_type
                where type_name in ('fundpool_match','kivapool_match'))
         	) min_times
        	where effective_time = min_eff_time
        	group by fund_account_id ) fid  on fid.fund_account_id = fa.id

			where fid.fundpool_match_first_item_id is not null
        	");*/
		$result = $this->db->query("select fund_account_id, fundpool_match_first_item_id, kivapool_match_first_item_id
			from $this->reference_schema.verse_dim_fund_account
			--where fundpool_match_first_item_id is not null
			-- random sample:
			where fund_account_id in (1351462, 565738, 1352542, 2139244)
			order by fund_account_id
			--and TO_CHAR(TO_TIMESTAMP(create_time), 'YYYYMMDD')::INT < 20150101");
		//$count_from_ods = $result->fetchColumn();
		$from_ods = $result->fetchAll();

		//$this->assertEquals($count_from_ods,$count_from_vertex);
		$this->assertSame($from_ods,$from_vertex);

	}

	public function testRandomItemIds() {
		$random_result = $this->db->query("	SELECT fund_account_id
			FROM
     		(SELECT fund_account_id
            , RANDOM() AS RandomNumber
     		FROM $this->reference_schema.verse_dim_fund_account
     		WHERE RANDOMINT((SELECT COUNT(*) FROM $this->reference_schema.verse_dim_fund_account ))%100 = 42
     		and (fundpool_match_first_item_id is not null or kivapool_match_first_item_id is not null)
     		) AS T1
			ORDER BY RandomNumber
			LIMIT 10");
		$random_ids = $random_result->fetchAll();

		for ($i = 0, $len = count($random_ids); $i < $len; $i++) {
			$id_array[] = $random_ids[$i]['fund_account_id'];
		}

		$id_list = implode(",",$id_array);
		//echo $id_list;

		$result = $this->db->query("select fund_account_id, fundpool_match_first_item_id, kivapool_match_first_item_id
			from $this->vertex_schema.vertex_dim_fund_account_first_item_ids
			where fund_account_id in ($id_list)
			order by fund_account_id");
		$from_vertex = $result->fetchAll();


		$result = $this->db->query("select fund_account_id, fundpool_match_first_item_id, kivapool_match_first_item_id
			from $this->reference_schema.verse_dim_fund_account
			where fund_account_id in ($id_list)
			order by fund_account_id");
		$from_ods = $result->fetchAll();

		$this->assertSame($from_ods,$from_vertex);

	}

	/**
	 * Asserts that two numbers are within the given margin.
	 *
	 * @param  $a - a number
	 * @param  $b - another number
	 * @param  $margin - the margin $a and $b should be within
	 * @param string $message - error message passed to assertTrue
	 */
	public function assertWithinMargin($a, $b, $margin, $message = '') {
		$this->assertTrue(abs($a - $b) < $margin, $message);
	}

}