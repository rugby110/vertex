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

	public function setUp() {
		$this->reference_schema = "verse_qa";
		$this->vertex_schema = getenv("vertex_vertica_target_schema");
		$this->user = getenv("vertex_vertica_user");
		$this->pwd = getenv("vertex_vertica_password");

		try {
			$this->db = new \PDO('odbc:vertica', $this->user, $this->pwd);
		} catch (PDOException $e) {
			echo $e->getMessage() . "\n";
		}
		echo "about to connect\n";

	}

	public function tearDown() {
		$this->db = null;
	}

	protected function assertPreconditions() {
		//echo "user: '$this->user' pwd: '$this->pwd' " . strlen($this->user) ;
		$this->assertGreaterThan(0, strlen($this->user),"Missing Vertex environment variable vertex_vertica_user. See vertex/conf/environment_variables.sh.");
		$this->assertGreaterThan(0, strlen($this->pwd),"Missing Vertex environment variable vertex_vertica_password. See vertex/conf/environment_variables.sh");
		$this->assertGreaterThan(0, strlen($this->vertex_schema),"Missing Vertex environment variable vertex_vertica_target_schema. See vertex/conf/environment_variables.sh");

	}
}


