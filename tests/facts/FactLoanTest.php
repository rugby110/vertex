<?php

/**
 * Class FactLoanTest
 *
 * Because vertex_fact_loan is a copy of vertex_dim_loan, all i'm testing is that there are no differences.
 * I'm leaving internal validity up to the test(s) for vertex_dim_loan
 */
class FactLoanTest extends Kiva\Vertex\Testing\VertexTestCase {

	public function testCount() {
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_fact_loan");
		$count_from_vertex_fact = $result->fetchColumn();

		//the fact is just a copy of the dim.
		$result = $this->db->query("select count(1) as how_many from $this->vertex_schema.vertex_dim_loan");
		$count_from_vertex_dim = $result->fetchColumn();

		$this->assertEquals($count_from_vertex_dim,$count_from_vertex_fact);
	}

	public function testLoanIds() {
		//fact loan_ids not in dim
		$result = $this->db->query("select count(1) from $this->vertex_schema.vertex_fact_loan where loan_id not in (select loan_id from $this->vertex_schema.vertex_dim_loan) ");
		$loan_ids_in_fact_but_not_dim = $result->fetchColumn();
		$this->assertEquals((int)$loan_ids_in_fact_but_not_dim, 0);

		//dim loan_ids not in fact
		$result = $this->db->query("select count(1) from $this->vertex_schema.vertex_dim_loan where loan_id not in (select loan_id from $this->vertex_schema.vertex_fact_loan) ");
		$loan_ids_in_dim_but_not_fact = $result->fetchColumn();
		$this->assertEquals((int)$loan_ids_in_dim_but_not_fact, 0);
	}
}