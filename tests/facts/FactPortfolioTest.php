<?php

/**
 * Class FactPortfolioTest
 *
 * NOTE:  the verse is kind of f@#$ for use as a reference:
 * 	1.  verse_fact_portfolio has 18 loans removed by hand(?), specifically for partner 337.  Here they are:
 * 			620414 ,654797 ,675808 ,696375 ,620419 ,623001 ,642511 ,669507 ,695816 ,629129 ,650591 ,669512, 675798, 675805 ,676510 ,695827 ,718003 ,718010
 *
 *  2.  there are instances where verse_fact_portfolio is out of sync with reality, like for loan_id 779560. (refunded, loan price 2450.00)
 * 		For this loan, the sum(total) is $1750 in verse_fact_portfolio.  But, the kiva db llp sum (and ods sum) is $1925.  Excluding promos (which we're not doing here anyway), the llp sum is $1850.
 * 		So... WTF.  I'm using the ods as the source of truth, not the verse here.
 *
 *  3.  There are 2 historical loans where the llps don't add up to loan price for ended loans: see testTotalForRaisedLoans()
 *
 */
class FactPortfolioTest extends Kiva\Vertex\Testing\VertexTestCase {

	/**
	 * NOTE: Historically, verse_fact_portfolio has 18 loans removed by hand(?), specifically for partner 337 - Banco Pérola
	 */
	public function testLoanIdCount() {
		$result = $this->db->query("select count(distinct loan_id) as how_many from $this->vertex_schema.vertex_fact_portfolio");
		$count_from_vertex = $result->fetchColumn();

		//the fact is just a copy of the dim.
		$result = $this->db->query("select count(distinct loan_id) as how_many from $this->reference_schema.verse_fact_portfolio");
		$count_from_verse = $result->fetchColumn();

		$this->assertEquals($count_from_vertex-18, $count_from_verse);
	}

	/**
	 * Let's make sure that any loan_id in dim_loan that dosn't appear in fact_portfolio never raised.
	 */
	public function testIntegrityWithDimLoan() {
		$result = $this->db->query("select distinct status from $this->vertex_schema.vertex_dim_loan where loan_id not in (select loan_id from $this->vertex_schema.vertex_fact_portfolio) and status in ('ended', 'payingBack', 'defaulted', 'raised')");
		$this->assertEquals(0, $result->rowCount());
	}

	public function testGender() {
		$result = $this->db->query("select distinct gender from $this->vertex_schema.vertex_fact_portfolio");
		$this->assertEquals(2, $result->rowCount());
	}

	/**
	 *
	 * Compare the totals for all loans that fully raised.  this ignores expirations and refunds of partially raised loans, but is a good check of our logic.
	 * There are two ancient loans where the llp's don't add up, so the diff is $50.
	 *
	 * select l.id, llp.llp_amt, l.price from loan l join
	 * (select loan_id, sum(purchase_amt) as llp_amt from lender_loan_purchase group by loan_id) llp on l.id = llp.loan_id
	 *  where l.status in ('payingBack', 'ended', 'defaulted', 'raised')
	 * and llp.llp_amt != l.price
	 * 57210	925.00	950.00
	   44276	475.00	500.00
	 *
	 */
	public function testTotalForRaisedLoans() {
		$result = $this->db->query("select sum(l.price) from $this->reference_schema.verse_ods_kiva_loan l where l.status in ('payingBack', 'ended', 'defaulted', 'raised')");
		$sum_loan = (int)$result->fetchColumn();

		$result = $this->db->query("select sum(v.total) from $this->vertex_schema.vertex_fact_portfolio v join $this->reference_schema.verse_ods_kiva_loan l on l.id = v.loan_id where l.status in ('payingBack', 'ended', 'defaulted', 'raised')");
		$sum_vertex = (int)$result->fetchColumn();

		$this->assertEquals($sum_vertex, $sum_loan-50);

	}
}