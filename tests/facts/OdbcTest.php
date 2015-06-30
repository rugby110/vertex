<?php
/**
 * Created by PhpStorm.
 * User: van
 * Date: 6/16/15
 * Time: 12:15 PM
 */
require 'vendor/autoload.php';

class OdbcTest extends PHPUnit_Framework_TestCase {
	private $user;
	private $pwd;

	public function setUp() {
		putenv("ODBCINI=/etc/odbc.ini");
		putenv("VERTICAINI=/etc/vertica.ini");

		$this->user = getenv("vertex_vertica_user");
		$this->pwd = getenv("vertex_vertica_password");

	    # Turn on error reporting
	    error_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE);

	}

	protected function errortrap_odbc($conn, $sql) {
		if(!$rs = odbc_exec($conn,$sql)) {
			echo "Failed to execute SQL: $sql" . odbc_errormsg($conn) . "\n";
		} else {
			//echo "Success: " . $sql . "\n";
		}
		return $rs;
	}

	protected function assertPreconditions() {
		//echo "user: '$this->user' pwd: '$this->pwd' " . strlen($this->user) ;
		$this->assertGreaterThan(0, strlen($this->user),"Missing Vertex environment variable vertex_vertica_user. See vertex/conf/environment_variables.sh.");
		$this->assertGreaterThan(0, strlen($this->pwd),"Missing Vertex environment variable vertex_vertica_password. See vertex/conf/environment_variables.sh");
	}

	public function testOdbc() {
		//$this->markTestSkipped();
		# Connect to the Database
		$dsn = "vertica";
		$conn = odbc_connect($dsn,$this->user,$this->pwd) or die ("CONNECTION ERROR");
		echo "Connected with DSN: $dsn" . "\n";

		# Create a table
		$sql = "select 1 from dual";

		$result = $this->errortrap_odbc($conn, $sql);
		echo $result;
		# Close the ODBC connection
		odbc_close($conn);
	}

}


