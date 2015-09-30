<?php //namespace Kiva\Vertex\Admin;

require_once __DIR__ . '/../../../vendor/autoload.php';

use Kiva\Vertex\Admin\Node;
use Kiva\Vertex\Admin\DependencyFinder;
use Kiva\Vertex\Admin\ViewMaterializer;

class SchemaMaterializer {
	protected $user;
	protected $pwd;
	protected $db;
	protected $destination_schema;
	protected $odbc_dsn;

	public function __construct() {
		$this->user = getenv("vertex_vertica_user");
		$this->pwd = getenv("vertex_vertica_password");
		$this->destination_schema = getenv("vertex_vertica_vertex_schema");
		$this->odbc_dsn = getenv("vertex_vertica_odbc_dsn");

		try {
			$this->db = new \PDO("odbc:" . $this->odbc_dsn, $this->user, $this->pwd);
			$this->db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		} catch (PDOException $e) {
			echo $e->getMessage() . "\n";
		}
	}

	public function run($source_schema) {

		exec("vsql -c \"select table_name, view_definition from v_catalog.views where table_name like 'vertex_%' and table_schema='" . $source_schema . "';\" -A -t 2>&1",$outputAndErrors,$return_value);
		print($outputAndErrors."\n");
		$views = array();
		foreach($outputAndErrors as $view_line) {
			// make sure we only split this into 2 parts (name and sql)
			$fields = explode("|",$view_line,2);
			$views[$fields[0]] = $fields[1];
		}

//		print_r($views);


		$fact_and_dim_nodes = array();
		// for each view, find its dependencies and build the graph for it
		foreach($views as $view_name => $view_sql) {
			// get the dependencies for the view
			$dependency_finder = new DependencyFinder();
			$references = $dependency_finder->getVertexFactDimDependencies($view_name, $view_sql);

			// if we don't already know about the node, add it in
			if (!array_key_exists($view_name,$fact_and_dim_nodes)) {
				$fact_and_dim_nodes[$view_name] = new Node($view_name);
			}

			// iterate over the dependencies to build the graph
			foreach($references as $referenced_fact_or_dim) {
				// only add dependencies that are views
				if (array_key_exists($referenced_fact_or_dim,$views)) {
					if (!array_key_exists($referenced_fact_or_dim,$fact_and_dim_nodes)) {
						$fact_and_dim_nodes[$referenced_fact_or_dim] = new Node($referenced_fact_or_dim);
					}
					$fact_and_dim_nodes[$view_name]->addEdge($fact_and_dim_nodes[$referenced_fact_or_dim]);
				}
			}
		}

		//print_r($fact_and_dim_nodes);
		$resolved = array();
		$unresolved = array();

		foreach($fact_and_dim_nodes as $fact_or_dim_node) {
			$fact_or_dim_node->resolveDependencies($fact_or_dim_node, $resolved, $unresolved);
		}

		$view_materializer = new ViewMaterializer($this->db);

		print("--------- dependency list ---------\n");
		foreach($resolved as $node) {
			$node->printNodeAndDependencies();
		}

		print("--------- materializing... ---------\n");
//////////////////
/*
// if we want to materialize from one schema to another, we need to copy tables over too
		$result = $this->db->query("select table_name
		from v_catalog.tables
		where table_schema='" . $source_schema . "'");
		$table_name_rows = $result->fetchAll();

		foreach($table_name_rows as $table_name_row) {
			$full_table_name = $table_name_row['table_name'];

			print("copying table: " . $full_table_name . " | ");
			$start = time();
			$view_materializer->materialize($full_table_name, $this->destination_schema);
			$end = time();
			print($end - $start . " second(s)\n");
		}
*/
///////////////
		// materialize the views in the resolved order in the default schema

		foreach($resolved as $node) {
			$view_name = $node->getName();
			print("materializing: " . $view_name . " | ");
			$start = time();
			$view_materializer->materializeInPlace($view_name);
			$end = time();
			print($end - $start . " second(s)\n");
		}

	}
}


if ($argc != 2) {
	print("Usage: php $argv[0] <schema name>\n
Find and materialize views from the given schema in place\n");
	exit;
}
$runner = new SchemaMaterializer();
$source_schema = $argv[1];
$runner->run($source_schema);