<?php namespace Kiva\Vertex\Admin;
/**
 * Find vertex fact dim dependencies based on sql file parsing.
 * This will be a useful approach for deployment dependencies, but for materialized views
 * we want to work off of Vertica metadata on deployed views.
 */

require_once __DIR__ . '/../../../vendor/autoload.php';

use Kiva\Vertex\Admin\Node;

class SqlDependencyFinder {
	protected $user;
	protected $pwd;
	protected $db;
	protected $odbc_dsn;

	public function run($path) {

		$facts_and_dims = array();

		$Directory = new \RecursiveDirectoryIterator($path);
		$Iterator = new \RecursiveIteratorIterator($Directory);
		$files = new \RegexIterator($Iterator, '/^.+\.sql$/i', \RecursiveRegexIterator::GET_MATCH);

		$fact_dim_regex = "/vertex_dim_[a-zA-Z0-9_]*\b|vertex_fact_[a-zA-Z0-9_]*\b/";
		foreach($files as $file) {
			$filename = $file[0];
		    echo "--------- ". $filename . PHP_EOL;
			$name_match = '';
			preg_match($fact_dim_regex, $filename,$name_match);
			$fact_or_dim_name = $name_match[0];
			print($fact_or_dim_name . "\n");

			$matching_lines = preg_grep($fact_dim_regex, file($file[0]));
			$matches = [];
			foreach($matching_lines as $matching_line) {
				preg_match($fact_dim_regex,$matching_line,$dim_matches);
				$matches = array_merge($matches, $dim_matches);
			}
			print("==all==");
			print_r($matches);
			$unique_matches = array_unique($matches);

			$key = array_search($fact_or_dim_name,$unique_matches);
			if($key!==false){
			    unset($unique_matches[$key]);
			}
			print("==unique==");
			print_r($unique_matches);

			if (!array_key_exists($fact_or_dim_name,$facts_and_dims)) {
				$facts_and_dims[$fact_or_dim_name] = new Node($fact_or_dim_name);
			}
			foreach($unique_matches as $referenced_fact_or_dim) {
				if (!array_key_exists($referenced_fact_or_dim,$facts_and_dims)) {
					$facts_and_dims[$referenced_fact_or_dim] = new Node($referenced_fact_or_dim);
				}
				$facts_and_dims[$fact_or_dim_name]->addEdge($facts_and_dims[$referenced_fact_or_dim]);
			}
		}
		print_r($facts_and_dims);
		$resolved = array();
		$unresolved = array();

		foreach($facts_and_dims as $fact_or_dim_node) {
			$fact_or_dim_node->resolveDependencies($fact_or_dim_node, $resolved, $unresolved);
		}
		print("--------- dependency list ---------\n");
		foreach($resolved as $node) {
			print($node->getName() . "\n");
		}
	}
}


if ($argc != 2) {
	print("Usage: php $argv[0] <root_foler>\n
Find things starting at the root_folder\n");
	exit;
}
$runner = new SqlDependencyFinder();
$dir_name = $argv[1];
$runner->run($dir_name);