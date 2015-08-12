<?php
/**
 * when deploying to the vertex schema, insure that
 * users are given permission to select from all views.
 */

$vertex_schema = getenv("vertex_vertica_vertex_schema");
$user = getenv("vertex_vertica_user");
$pwd = getenv("vertex_vertica_password");
$odbc_dsn = getenv("vertex_vertica_odbc_dsn");

// don't do anything if it is a developer deploy
if ($vertex_schema != "vertex") {
	print "No permissions to update for a non-vertex deploy.\n";
	exit(0);
}

try {
	$db = new \PDO("odbc:" . $odbc_dsn, $user, $pwd);
} catch (PDOException $e) {
     die("DB ERROR: ". $e->getMessage());
}

$results = $db->query("select table_name from v_catalog.all_tables where schema_name = '" . $vertex_schema .
		"' and table_type='VIEW'");

foreach($results as $result) {
	$grant_statement = "grant select on " . $vertex_schema . "." . $result['table_name'] . " to vertex_read_only_view_role";
	print "running: " . $grant_statement . "\n";
	try {
		$db->exec($grant_statement);
	} catch (PDOException $e) {
      die("DB ERROR: ". $e->getMessage());
  	}
}