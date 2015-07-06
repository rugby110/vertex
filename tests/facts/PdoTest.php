<?php
/**
 * Created by PhpStorm.
 * User: van
 * Date: 6/16/15
 * Time: 12:15 PM
 */
require 'vendor/autoload.php';

class PdoTest extends PHPUnit_Framework_TestCase {
	private $user;
	private $pwd;
	private $db;

	public function setUp() {
		$this->user = getenv("vertex_vertica_user");
		$this->pwd = getenv("vertex_vertica_password");

		try {
			$this->db = new PDO('odbc:vertica', $this->user, $this->pwd);
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


		echo "connected\n";
		$result = $this->db->query("select country_id, name from verse_qa.verse_dim_country order by name limit 10");

		$this->assertCount(10,$result->fetchAll());
	}
}


