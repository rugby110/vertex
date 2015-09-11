/**
Creates vertex_fact_loan

The fact table is identical to the dim, other than the col pointing to the old verse v_id col.
		Fact to dim for loan should now be joined on loan_id, if necessary.
TODO: Measures and attributes should be broken out at some point.  We shouldn't have attributes as facts and measures as dims, right?
*/

create or replace view vertex_fact_loan as
select * from vertex_dim_loan