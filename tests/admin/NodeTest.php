<?php
use Kiva\Vertex\Admin\Node;

class NodeTest extends PHPUnit_Framework_TestCase {
	public function testWalkDependencies() {
		$a = new Node('a');
		$b = new Node('b');
		$c = new Node('c');
		$d = new Node('d');
		$e = new Node('e');

		$f = new Node('f');
		$g = new Node('g');

		$a->addEdge($b); // a depend on b...
		$a->addEdge($d);
		$b->addEdge($c);
		$b->addEdge($e);
		$c->addEdge($d);
		$c->addEdge($e);

		// add a disconnected edge
		$f->addEdge($g);

		$nodes = array();
		$a->walkDependencies($nodes);

		$index = 0;
		$expected_node_order = array('a', 'b', 'c', 'd', 'e', 'e', 'd');
		foreach($nodes as $node) {
			$this->assertEquals($expected_node_order[$index++], $node->getName());
		}

	}
	public function testResolveDependencies() {
		$a = new Node('a');
		$b = new Node('b');
		$c = new Node('c');
		$d = new Node('d');
		$e = new Node('e');

		$f = new Node('f');
		$g = new Node('g');

		$a->addEdge($b); // a depend on b...
		$a->addEdge($d);
		$b->addEdge($c);
		$b->addEdge($e);
		$c->addEdge($d);
		$c->addEdge($e);

		// add a disconnected edge
		$f->addEdge($g);

		$resolved = array();
		$unresolved = array();
		$a->resolveDependencies($a, $resolved, $unresolved);
		$f->resolveDependencies($f, $resolved, $unresolved);

		$index = 0;
		$expected_node_order = array('d', 'e', 'c', 'b', 'a', 'g', 'f');
		foreach($resolved as $a_node) {
			$this->assertEquals($expected_node_order[$index++], $a_node->getName());
		}
	}
}
