<?php namespace Kiva\Vertex\Admin;
/**
 * Class DependencyFinder
 *
 * Find the vertex facts and dimensions that a given view depends on.
 *
 * @package Kiva\Vertex\Admin
 */
class DependencyFinder {

	/**
	 * @param $view_name name of the view defined in the sql
	 * @param $view_sql sql to search for dependencies
	 * @return array of dependencies as view names
	 */
	public function getVertexFactDimDependencies($view_name, $view_sql)
	{
		$regex_matches = [];
//		$fact_dim_regex = "/vertex_dim_[a-zA-Z0-9_]*\b|vertex_fact_[a-zA-Z0-9_]*\b/";
		$fact_dim_regex = "/vertex_[a-zA-Z0-9_]*\b/";
		preg_match_all($fact_dim_regex, $view_sql, $regex_matches);
		$matches = $regex_matches[0];

		// remove the view_name itself from the list of dependencies
		$key = array_search($view_name,$matches);
		while ($key!==false){
		    unset($matches[$key]);
			$key = array_search($view_name,$matches);
		}

		// remove duplicated dependencies
		$matches = array_unique($matches);

		// remove any gaps in the array for the return value
		return array_values(array_filter($matches));
	}
}
