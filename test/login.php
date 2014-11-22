<?php
require_once __DIR__ . '/../config.php';

$dbh = $connections['unsafe'];
$error = false;
$errorMsg = '';

if (isset($_POST['submit'])) {
    if (empty($_POST['un']) || empty($_POST['pw'])) {
        $error = true;
        $errorMsg = 'Provide both username and password';
    } else {
        $user = $_POST['un'];
        $pass = $_POST['pw'];
        $query = "SELECT * FROM user_account WHERE username = '$user' AND password = '$pass'";
        echo $query;
        $res = pg_query($dbh, $query);

        if (pg_num_rows($res) > 0) {
            $row = pg_fetch_assoc($res);
            $errorMsg = 'Welcome to your email: ' . $row['email'];
            $_SESSION['user'] = $row['username'];
            header('Location: restricted.php');
            exit;
        } else {
            $error = true;
            $errorMsg = 'Invalid credentials';
        }
    }
}
?>
<!doctype html>
<html>
<head>
    <title>Vulnerability Test 1</title>
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" type="text/css" />
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-lg-6 col-md-8 col-sm-12 col-lg-offset-3 col-md-offset-2">
                <div class="page-header">
                    <h2>login</h2>
                </div>
                <?php
                if ($error && !empty($errorMsg)):
                ?>
                <div class="alert alert-danger">
                    <?php echo $errorMsg; ?>
                </div>
                <?php
                elseif (!$error && !empty($errorMsg)):
                ?>
                <div class="alert alert-success">
                    <?php echo $errorMsg; ?>
                </div>
                <?php endif; ?>
                <form method="post" class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-3 control-label" for="un">
                        Username
                        </label>
                        <div class="col-sm-9">
                            <input type="text" id="un" name="un" class="form-control" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-3 control-label" for="pw">
                        Password
                        </label>
                        <div class="col-sm-9">
                            <input type="password" id="pw" name="pw" class="form-control" />
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-9 col-sm-offset-3">
                            <button type="submit" class="btn btn-primary" name="submit">
                                Login
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
