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
		where table_schema='$this->reference_schema'
			and (table_name like 'verse_ods_kiva%'
			 or table_name like 'verse_ods_k2%'
			 or table_name like 'verse_ods_www%'
			 or table_name like 'verse_ods_zip%'
			 or table_name = 'verse_ods_eventlog')");
		$table_name_rows = $result->fetchAll();

		// array (old_prefix => new_prefix)
		$prefixes = array(
			'verse_ods_kiva_'  =>  '',
			'verse_ods_k2_'    =>  'zip_k2_',
			'verse_ods_www_'   =>  'www_',
			'verse_ods_zip_'   =>  'zip_'
		);
		$statements_run = 0;
		foreach($table_name_rows as $table_name_row) {
			$full_table_name = $table_name_row['table_name'];
			if ($full_table_name == 'verse_ods_eventlog') {
				$short_table_name = 'eventlog';
			} else {
				foreach ($prefixes as $old => $new) {
					if (substr_count($full_table_name, $old)) {
						$short_table_name = $new . substr($full_table_name, strlen($old));
					}
				}
			}

			//print($full_table_name . ',' . $short_table_name . "\n");
			$view_sql = "create or replace view ods_kiva.$short_table_name as select * from $this->reference_schema.$full_table_name;";
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

$mapper = new KivaDbTableMapper();
$mapper->run();