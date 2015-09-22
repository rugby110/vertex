<?php
/**
 * Map verse.verse_ods_kiva_tablename to ods_kiva.tablename
 */

class KivaDbTableMapper {
	protected $user;
	protected $pwd;
	protected $db;

	protected $reference_schema;
	protected $vertex_schema;
	protected $odbc_dsn;

	public function run() {

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

		$result = $this->db->query("select table_name
		from v_catalog.tables
		where table_schema='$this->reference_schema' and table_name like 'verse_ods_kiva%'");
		$table_name_rows = $result->fetchAll();

		$statements_run = 0;
		foreach($table_name_rows as $table_name_row) {
			$full_table_name = $table_name_row['table_name'];
			$short_table_name = substr($full_table_name,strlen('verse_ods_kiva_'));
			//print($full_table_name . ',' . $short_table_name . "\n");
			$view_sql = "create or replace view ods_kiva.$short_table_name as select * from $this->reference_schema.$full_table_name;";
			print($view_sql . "\n");
			$statements_run++;
			try {
				//$this->db->exec($view_sql);
			} catch (PDOException $e) {
				echo 'Connection failed: ' . $e->getMessage();
				exit;
			}
		}

	}
}

$mapper = new KivaDbTableMapper();
$mapper->run();