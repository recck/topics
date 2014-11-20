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
