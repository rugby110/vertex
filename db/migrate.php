#!/usr/bin/env php
<?php
/**
 * Created by PhpStorm.
 * User: sam
 * Date: 8/7/15
 * Time: 12:49 PM
 */

require_once( dirname(__FILE__) . '/db_config.php');
//var_dump($db_config);
include (dirname(__FILE__) . '/../vendor/davesloan/mysql-php-migrations/migrate.php');
