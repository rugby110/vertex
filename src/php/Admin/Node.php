<?php namespace Kiva\Vertex\Admin;

class Node
{
	private $name;
	private $edges;

	public function __construct($name)
	{
		$this->name = $name;
		$this->edges = array();
	}

	public function addEdge($node)
	{
		$this->edges[$node->getName()] = $node;
	}

	public function getName()
	{
		return $this->name;
	}

	public function getEdges()
	{
		return $this->edges;
	}

	public function walkDependencies(&$nodes)
	{
		//print($this->getName() . "\n");
		$nodes[] = $this;

		foreach ($this->edges as $edge) {
			$edge->walkDependencies($nodes);
		}
		return $nodes;
	}

	public function printNodeAndDependencies($indent="")
	{
		print($indent . $this->getName() . "\n");
		$indent = $indent . "   ";
		foreach ($this->edges as $edge) {
			$edge->printNodeAndDependencies($indent);
		}
	}

	public function resolveDependencies($node, &$resolved, &$unresolved)
	{
		$unresolved[$node->getName()] = $node;
		foreach ($node->getEdges() as $edge) {
			if (!array_key_exists($edge->getName(), $resolved)) {
				if (array_key_exists($edge->getName(), $unresolved)) {
					throw new \Exception("Circular reference detected: " . $node->getName() . " -> " . $edge->getName());
				}
				$this->resolveDependencies($edge, $resolved, $unresolved);
			}
		}
		$resolved[$node->getName()] = $node;
		unset($unresolved[$node->getName()]);
	}
}
