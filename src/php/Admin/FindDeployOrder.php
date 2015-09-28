<?php //namespace Kiva\Vertex\Admin;

require_once __DIR__ . '/../../../vendor/autoload.php';

use Kiva\Vertex\Admin\Node;
use Kiva\Vertex\Admin\DependencyFinder;

class FindDeployOrder {


	public function run($path) {

		$facts_and_dims = array();

		$Directory = new \RecursiveDirectoryIterator($path);
		$Iterator = new \RecursiveIteratorIterator($Directory);
		$files = new \RegexIterator($Iterator, '/^.+\.sql$/i', \RecursiveRegexIterator::GET_MATCH);

		$views = array();
		$view_to_file = array();

		//$fact_dim_regex = "/vertex_dim_[a-zA-Z0-9_]*\b|vertex_fact_[a-zA-Z0-9_]*\b/";
		$fact_dim_regex = "/(vertex_[a-zA-Z0-9_]*)\.sql/";
		foreach($files as $file) {
			$filename = $file[0];
			//echo "--------- " . $filename . PHP_EOL;
			$name_match = '';
			preg_match($fact_dim_regex, $filename,$name_match);
			$fact_or_dim_name = substr($name_match[0], 0,strlen($name_match[0])-4);
			//print($fact_or_dim_name . "\n\n");

			$file_content = file_get_contents($filename);
			//print($file_content . "\n\n\n");

			// get rid of /*  */ comments
			$file_content = preg_replace("/(\/\*([^*]|(\*+[^*\/]))*\*+\/)/",'',$file_content);
			// get rid of // comments
			$file_content = preg_replace("/(\-\-.*)/",'',$file_content);

			//print($file_content . "\n\n\n");
			$views[$fact_or_dim_name] = $file_content;
			$view_to_file[$fact_or_dim_name] = $filename;

		}
		//print_r($views);
		//print_r($view_to_file);
		//exit;


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

//		print("--------- dependency list ---------\n");
		foreach($resolved as $node) {
			//$node->printNodeAndDependencies();
			$view_name = $node->getName();
			print($view_to_file[$view_name] . "\n");
		}
	}
}


if ($argc != 2) {
	print("Usage: php $argv[0] <root_foler>\n
Find things starting at the root_folder\n");
	exit;
}
$runner = new FindDeployOrder();
$dir_name = $argv[1];
$runner->run($dir_name);