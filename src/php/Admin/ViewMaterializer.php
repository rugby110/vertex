<?php namespace Kiva\Vertex\Admin;


class ViewMaterializer {
	/** @var  \PDO */
	private $pdo;

	public function __construct($pdo) {
		$this->pdo = $pdo;
	}

	public function materialize($view_name) {
		$materialized_view_name = $view_name . "_materialized";
		// select * into materialize_tmp
		$materialize_sql = "select *  into " . $materialized_view_name . " from " . $view_name;
		$this->pdo->exec($materialize_sql);

		// swap the materialized view for original view
		$this->pdo->beginTransaction();
		$this->pdo->exec("drop view $view_name");
		$rename_sql = "alter table $materialized_view_name rename to $view_name";
		$this->pdo->exec($rename_sql);
		$this->pdo->commit();

	}
}