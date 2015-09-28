<?php
/**
 * Drop tables and views in a given schema.
 */

class DropAllTablesAndViews {
	protected $user;
	protected $pwd;
	protected $db;

	protected $reference_schema;
	protected $vertex_schema;
	protected $odbc_dsn;

	public function run() {

		$this->user = getenv("vertex_vertica_user");
		$this->pwd = getenv("vertex_vertica_password");
		$this->odbc_dsn = getenv("vertex_vertica_odbc_dsn");

		try {
			$this->db = new \PDO("odbc:" . $this->odbc_dsn, $this->user, $this->pwd);
			$this->db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		} catch (PDOException $e) {
			echo $e->getMessage() . "\n";
		}

		print("Do you really want to delete all tables and views in your schema?(y/n)");
		$input = trim(fgets(STDIN));

		if ($input != 'y') {
			exit;
		}

		$result = $this->db->query("select table_name
		from v_catalog.tables
		where table_schema='van'");
		$table_name_rows = $result->fetchAll();

		$statements_run = 0;
		foreach($table_name_rows as $table_name_row) {
			$full_table_name = $table_name_row['table_name'];

			print("dropping table $full_table_name \n");
			$view_sql = "drop table $full_table_name;";
			//print($view_sql . "\n");
			$statements_run++;
			try {
				$this->db->exec($view_sql);
			} catch (PDOException $e) {
				echo 'Connection failed: ' . $e->getMessage();
				exit;
			}
		}

		$result = $this->db->query("select table_name
		from v_catalog.views
		where table_schema='van'");
		$table_name_rows = $result->fetchAll();

		$statements_run = 0;
		foreach($table_name_rows as $table_name_row) {
			$full_table_name = $table_name_row['table_name'];

			print("dropping view $full_table_name \n");
			$view_sql = "drop view $full_table_name;";
			//print($view_sql . "\n");
			$statements_run++;
			try {
				$this->db->exec($view_sql);
			} catch (PDOException $e) {
				echo 'Connection failed: ' . $e->getMessage();
				exit;
			}
		}


	}
}

$mapper = new DropAllTablesAndViews();
$mapper->run();