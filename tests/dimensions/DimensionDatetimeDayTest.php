<?php

class DimensionDatetimeDayTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_datetime_day");
		$count_from_vertex = $result->fetchColumn();

		$fifty_years_of_days = 50 * 365;
		$this->assertEquals($fifty_years_of_days,$count_from_vertex);
	}

	public function testSampleEntry() {
		$result = $this->db->query("select * from " . $this->vertex_schema . ".vertex_dim_datetime_day where id = 20050403");
		$row= $result->fetch(PDO::FETCH_ASSOC);
		// 	false	true	true	200502	20050204

		$this->assertEquals(20050403,$row['id']);
		$this->assertEquals(1112486400,$row['full_time']);
		$this->assertEquals(2005,$row['year']);
		$this->assertEquals(2,$row['quarter']);
		$this->assertEquals(4,$row['month']);
		$this->assertEquals(3,$row['day']);
		$this->assertEquals('2005',$row['year_label']);

		$this->assertEquals('2',$row['quarter_label_short']);
		$this->assertEquals('Q2',$row['quarter_label_long']);
		$this->assertEquals('2005-Q2',$row['quarter_label_human']);

		$this->assertEquals('Apr',$row['month_label_short']);
		$this->assertEquals('April',$row['month_label_long']);
		$this->assertEquals('2005-Apr',$row['month_label_human']);

		$this->assertEquals('Apr 14',$row['week_label_short']);
		$this->assertEquals('April 14',$row['week_label_long']);
		$this->assertEquals('2005-Apr-14 wk',$row['week_label_human']);

		$this->assertEquals('03',$row['day_label_short']);
		$this->assertEquals('3rd',$row['day_label_long']);
		$this->assertEquals('2005-Apr-03',$row['day_label_human']);

		$this->assertEquals(7,$row['day_in_week']);
		$this->assertEquals(false,(bool)$row['is_last_day_in_month']);

		$this->assertEquals('Sun',$row['day_name_short']);
		$this->assertEquals('Sunday',$row['day_name_long']);

		$this->assertEquals(false,(bool)$row['is_first_day_in_week']);
		$this->assertEquals(true,(bool)$row['is_last_day_in_week']);
		$this->assertEquals(true,(bool)$row['is_weekend']);

		$this->assertEquals(200502,$row['year_quarter']);
		$this->assertEquals(20050204,$row['year_quarter_month']);
	}


}


