<?php
/**
 * Run a sql file using the configured PDO ODBC connectino to Vertex
 */

class SqlRunner {
	protected $user;
	protected $pwd;
	protected $db;
	protected $odbc_dsn;

	public function run($file_name) {

		$this->user = getenv("vertex_vertica_user");
		$this->pwd = getenv("vertex_vertica_password");
		$this->odbc_dsn = getenv("vertex_vertica_odbc_dsn");

		try {
			$this->db = new \PDO("odbc:" . $this->odbc_dsn, $this->user, $this->pwd);
			$this->db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		} catch (PDOException $e) {
			echo $e->getMessage() . "\n";
		}

		$sql_to_run = file_get_contents($file_name);

		try {
			$this->db->exec($sql_to_run);
		} catch (PDOException $e) {
			echo 'SQL error: ' . $e->getMessage() . "\n";
			exit;
		}

	}
}

if ($argc != 2) {
	print("Usage: php $argv[0] <sql_filename>\n
The SQL in <sql_filename> will be run using the username, password and ODBC DSN as
specified in the environment variables:
vertex_vertica_user
vertex_vertica_password
vertex_vertica_odbc_dsn\n");
	exit;
}
$runner = new SqlRunner();
$file_name = $argv[1];
$runner->run($file_name);