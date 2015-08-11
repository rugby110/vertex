<?php namespace Kiva\Vertex\Testing;
/**
 * Created by PhpStorm.
 * User: van
 * Date: 6/16/15
 * Time: 12:15 PM
 */

class VertexTestCase extends \PHPUnit_Framework_TestCase{
	protected $user;
	protected $pwd;
	protected $db;

	protected $reference_schema;
	protected $vertex_schema;
	protected $odbc_dsn;

	public function setUp() {
		parent::setUp();

		$this->reference_schema = getenv("vertex_vertica_reference_schema");
		$this->vertex_schema = getenv("vertex_vertica_vertex_schema");
		$this->user = getenv("vertex_vertica_user");
		$this->pwd = getenv("vertex_vertica_password");
		$this->odbc_dsn = getenv("vertex_vertica_odbc_dsn");

		try {
			$this->db = new \PDO("odbc:" . $this->odbc_dsn, $this->user, $this->pwd);
		} catch (PDOException $e) {
			echo $e->getMessage() . "\n";
		}

	}

	public function tearDown() {
		parent::tearDown();

		$this->db = null;
	}

	protected function assertPreconditions() {
		//echo "user: '$this->user' pwd: '$this->pwd' " . strlen($this->user) ;
		$this->assertGreaterThan(0, strlen($this->user),"Missing Vertex environment variable vertex_vertica_user. See vertex/conf/environment_variables.sh.");
		$this->assertGreaterThan(0, strlen($this->pwd),"Missing Vertex environment variable vertex_vertica_password. See vertex/conf/environment_variables.sh");
		$this->assertGreaterThan(0, strlen($this->reference_schema),"Missing Vertex environment variable vertex_reference_target_schema. See vertex/conf/environment_variables.sh");
		$this->assertGreaterThan(0, strlen($this->vertex_schema),"Missing Vertex environment variable vertex_vertica_vertex_schema. See vertex/conf/environment_variables.sh");
		$this->assertGreaterThan(0, strlen($this->odbc_dsn),"Missing Vertex environment variable vertex_vertica_odbc_dsn. See vertex/conf/environment_variables.sh");

	}
}


