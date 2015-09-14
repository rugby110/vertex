<?php

class DimensionDatetimeMonthTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testTotalCount() {
		$result = $this->db->query("select count(*) as how_many from $this->vertex_schema.vertex_dim_datetime_month");
		$count_from_vertex = $result->fetchColumn();

		$fifty_years_of_months = 50 * 12;
		$this->assertEquals($fifty_years_of_months,$count_from_vertex);
	}

	public function testSampleEntry() {
		$result = $this->db->query("select * from " . $this->vertex_schema . ".vertex_dim_datetime_month where datetime_month_id = 200504");
		$row= $result->fetch(PDO::FETCH_ASSOC);

		$this->assertEquals(200504,$row['datetime_month_id']);
		$this->assertEquals(mktime(0,0,0,4,1,2005),$row['full_time']);
		$this->assertEquals(2005,$row['year']);
		$this->assertEquals(2,$row['quarter']);
		$this->assertEquals(4,$row['month']);
		$this->assertEquals('2005',$row['year_label']);

		$this->assertEquals('2',$row['quarter_label_short']);
		$this->assertEquals('Q2',$row['quarter_label_long']);
		$this->assertEquals('2005-Q2',$row['quarter_label_human']);

		$this->assertEquals('Apr',$row['month_label_short']);
		$this->assertEquals('April',$row['month_label_long']);
		$this->assertEquals('2005-Apr',$row['month_label_human']);

		$this->assertEquals(200502,$row['year_quarter']);
		$this->assertEquals(20050204,$row['year_quarter_month']);
	}


}


