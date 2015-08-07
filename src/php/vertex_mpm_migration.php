<?php
/**
 * Created by PhpStorm.
 * User: sam
 * Date: 8/7/15
 * Time: 1:16 PM
 */
abstract class VertexMpmMigration extends MpmMigration {
	/**
	 *
	 */
	function __construct() {
		parent::__construct();

		// grab this stuff from the same place mpm expects its config
		$db_config = $GLOBALS['db_config'];

		// setup / validate connection to mysql staging slave
		$pdo_settings = array
		(
			PDO::ATTR_PERSISTENT => true,
			PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
		);
		$this->mysqlObj = new PDO($db_config->slave_dsn, null, null, $pdo_settings);

		// validate trepctl credentials?
		$this->trepctlCommand = $db_config['trepctl_command'];
	}

	/**
	 * @var PDO $mysqlObj
	 */
	protected $mysqlObj;

	protected function stopMysqlSlave() {
		$this->mysqlObj->exec("STOP SLAVE SQL_THREAD");
	}

	protected function startMysqlSlave() {
		$this->mysqlObj->exec("START SLAVE");
	}

	protected function showMysqlSlaveStatus() {
		$this->mysqlObj->query("SHOW SLAVE STATUS");
	}

	/* @var string */
	protected $trepctlCommand;

	protected function setTungstenOffline() {
		// trepctl offline
		passthru($this->trepctlCommand . ' offline');
	}

	protected function setTungstenOnline() {
		// trepctl online
		passthru($this->trepctlCommand . ' online');
	}

	protected function getTungstenStatus() {
		// trepctl status
		passthru($this->trepctlCommand . ' status');
	}

	/**
	 * As the name implies, these are so simple that no tungsten / staging manipulation is needed
	 *
	 * @param array $ddl_statements
	 */
	protected function doItLive($ddl_statements, PDO &$vertica) {
		foreach ($ddl_statements as $ddl) {
			$vertica->exec($ddl);
		}
	}

	/**
	 * Just need to take Tungsten offline while this is running.
	 *
	 * @param array $ddl_statements
	 */
	protected function doItOffline($ddl_statements, PDO &$vertica) {
		$this->setTungstenOffline();
		foreach ($ddl_statements as $ddl) {
			$vertica->exec($ddl);
		}
		$this->setTungstenOnline();
	}

	/**
	 * The most complicated scenario.
	 * Not only take Tungsten offline and stop the staging slave,
	 *  but after the DDL has been applied on the Vertica side,
	 *  also reload the whole table by running all the rows through the mysql binlog again.
	 *
	 * see also https://docs.continuent.com/tungsten-replicator-4.0/deployment-seeddata-mysql.html
	 *
	 * @param array $tables eg array( 'credit_change' => array($ddl1, $ddl2) )
	 */
	protected function doItAndReload($tables, PDO &$vertica) {

		$this->stopMysqlSlave();
		// optional: wait for Tungsten to finish processing it all
		//   aka, "Check Tungsten Replicator status on all servers to make sure it is ONLINE and that the appliedLastSeqno values are matching"
		$this->setTungstenOffline();
		// optional: wait for Vertica to finish processing any statements in progress

		foreach ($tables as $table => $ddl_statements) {

			foreach ($ddl_statements as $ddl) {
				$vertica->exec($ddl);
			}

			// all done with the DDL!
			// now time to reload the table

			// reload all the rows
			//   does the current Verse code have a more efficient way of doing this?
			$filename = '/tmp/' . $table . '.sql';
			$this->mysqlObj->exec("SELECT * FROM $table INTO OUTFILE $filename");
			$this->mysqlObj->exec("LOAD DATE INFILE $filename");

		}

		// finally...
		$this->setTungstenOnline();
		$this->startMysqlSlave();

	}

}