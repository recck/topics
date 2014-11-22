<?php
/**
 * User: Marcus
 * Date: 11/22/2014
 * Time: 3:29 PM
 */

require_once __DIR__ . '/../config.php';

if (isset($_SESSION['user'])) {
    $query = "SELECT * FROM user_account WHERE username = '" . $_SESSION['user'] . "'";
    $res = pg_query($query);
    $row = pg_fetch_assoc($res);

    echo '<h1>welcome ' . $_SESSION['user'] . '</h1>';
    echo '<h3>your email is: ' . $row['email'] . '</h3>';
} else {
    echo 'this page is restricted';
}