<?php
$info = parse_ini_file("../config.ini", true);
$db = $info['db_info'];

$dsn = sprintf("host=%s port=%d dbname=%s user=%s password=%s",
        $db['db_host'],
        $db['db_port'],
        $db['db_name'],
        $db['db_user'],
        $db['db_pass']);

$connections = array(
    'unsafe' => pg_connect($dsn),
    'safe' => new PDO('pgsql:' . $dsn)
);

