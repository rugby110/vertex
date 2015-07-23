<?php
/**
 * Created by PhpStorm.
 * User: van
 * Date: 6/16/15
 * Time: 12:15 PM
 */

class PdoTest extends PHPUnit_Framework_TestCase {
	private $user;
	private $pwd;
	private $db;
	private $verse_schema;
	private $odbc_dsn;

	public function setUp() {
		$this->user = getenv("vertex_vertica_user");
		$this->pwd = getenv("vertex_vertica_password");
		$this->verse_schema = getenv("vertex_vertica_verse_schema");
		$this->odbc_dsn = getenv("vertex_vertica_odbc_dsn");

		print("DSN: " . $this->odbc_dsn . "\n");

		try {
			$this->db = new PDO("odbc:" . $this->odbc_dsn, $this->user, $this->pwd);
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
	}

	public function testPDO() {
		$query = "select country_id, name from " . $this->verse_schema . ".verse_dim_country order by name limit 10";
		echo "$query\n";
		$result = $this->db->query($query);

		$this->assertCount(10,$result->fetchAll());
	}
}


