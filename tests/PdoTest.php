<?php
/**
 * Created by PhpStorm.
 * User: van
 * Date: 6/16/15
 * Time: 12:15 PM
 */

class PdoTest extends Kiva\Vertex\Testing\VertexTestCase {
	public function setUp() {
		parent::setUp();
	}

	public function tearDown() {
		parent::tearDown();
	}

	public function testPDO() {
		$query = "select country_id, name from " . $this->reference_schema . ".verse_dim_country order by name limit 10";
		$result = $this->db->query($query);

		$this->assertCount(10,$result->fetchAll());
	}
}


