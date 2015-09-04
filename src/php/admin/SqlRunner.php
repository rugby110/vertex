<?php
/**
 * Run a sql file using the configured PDO ODBC connectino to Vertex
 */

class SqlRunner {
	protected $user;
	protected $pwd;
	protected $db;

	protected $reference_schema;
	protected $vertex_schema;
	protected $odbc_dsn;

	public function run($file_name) {

		$this->reference_schema = getenv("vertex_vertica_reference_schema");
		$this->vertex_schema = getenv("vertex_vertica_vertex_schema");
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

		//print($sql_to_run . "\n");
		try {
			$this->db->exec($sql_to_run);
		} catch (PDOException $e) {
			echo 'SQL error: ' . $e->getMessage() . "\n";
			exit;
		}

	}
}

$runner = new SqlRunner();
$file_name = $argv[1];
$runner->run($file_name);