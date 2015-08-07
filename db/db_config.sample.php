<?php

$db_config = (object) array();

$db_config->db_path = dirname(__FILE__); // this directory
$db_config->method = 1; // MPM_METHOD_PDO
$db_config->migrations_table = 'mpm_migrations';

$db_config->pdo_dsn = 'vertex_dev'; // Most of the magic actually defined in an ODBC .ini file
$db_config->mysql_dsn = 'vertex_staging_dev';
$db_config->trepctl_command = 'path/to/trepctl with options';

// END