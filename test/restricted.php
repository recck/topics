<?php
/**
 * User: Marcus
 * Date: 11/22/2014
 * Time: 3:29 PM
 */

require_once __DIR__ . '/../config.php';

if (isset($_SESSION['user'])) {
    echo '<h1>welcome ' . $_SESSION['user'] . '</h1>';
} else {
    echo 'this page is restricted';
}