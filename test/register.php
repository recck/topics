<?php
/**
 * Created by PhpStorm.
 * User: Marcus
 * Date: 11/20/2014
 * Time: 9:02 PM
 */

require_once __DIR__ . '/../config.php';

$dbh = $connections['unsafe'];

$error = false;
$errorMsg = '';

if (isset($_POST['submit'])) {
    $fields = array('un','pw','cpw','email');
    $empty = array();

    foreach ($fields as $key) {
        if (empty($_POST[$key])) {
            $empty[] = $key;
        }
    }

    if (!empty($empty)) {
        $error = true;
        $errorMsg = 'Please supply all fields!';
    } else {
        $user = $_POST['un'];
        $pass = $_POST['pw'];
        $conf = $_POST['cpw'];
        $email = $_POST['email'];

        if ($pass !== $conf) {
            $error = true;
            $errorMsg = 'Passwords dont match';
        } else {
            $query = "INSERT INTO user_account (username, password, email) VALUES('$user', '$pass', '$email')";
            $res = pg_query($dbh, $query);

            if ($res) {
                header('Location: thankyou.php?user=' . $user);
                exit;
            } else {
                $error = true;
                $errorMsg = 'Something went wrong, check your information';
            }
        }
    }
}
?>
<!doctype html>
<html>
<head>
    <title>Register for Vulnerable</title>
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" type="text/css" />
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-lg-6 col-md-8 col-sm-12 col-lg-offset-3 col-md-offset-2">
                <div class="page-header">
                    <h2>register</h2>
                </div>
                <?php if($error): ?>
                <div class="alert alert-danger">
                    <?php echo $errorMsg; ?>
                </div>
                <?php endif; ?>
                <form method="post" class="form-horizontal">
                    <div class="form-group">
                        <label class="control-label col-sm-3" for="un">
                            Username
                        </label>
                        <div class="col-sm-9">
                            <input type="text" name="un" id="un" class="form-control" placeholder="username" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="control-label col-sm-3" for="pw">
                            Password
                        </label>
                        <div class="col-sm-9">
                            <input type="password" name="pw" id="pw" class="form-control" placeholder="..." />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="control-label col-sm-3" for="cpw">
                            Confirm
                        </label>
                        <div class="col-sm-9">
                            <input type="password" name="cpw" id="cpw" class="form-control" placeholder="..." />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="control-label col-sm-3" for="email">
                            Email Address
                        </label>
                        <div class="col-sm-9">
                            <input type="text" name="email" id="email" class="form-control" placeholder="tjb@cs.rit.edu" />
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-9 col-sm-offset-3">
                            <button type="submit" name="submit" class="btn btn-success btn-block">
                                Register
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>