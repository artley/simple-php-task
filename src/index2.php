<?

ini_set('session.save_handler', 'redis');
ini_set('session.save_path', "tcp://develop-redis-rg.tpuvcs.ng.0001.euw1.cache.amazonaws.com:6379");

error_reporting(-1);
session_start();

pg_connect("host='develop-postgres.c47lapqr8apm.eu-west-1.rds.amazonaws.com' dbname='simplyanalytics' user='demo' password='12345678!'");

$state = 'authenticating';

if (!empty($_SESSION['username'])) {
    $state = 'authenticated';
} else if (!empty($_POST['username']) && !empty($_POST['password'])) {
    if (passwordMatches($_POST['username'], $_POST['password'])) {
        $_SESSION['username'] = $_POST['username'];
        $state = 'authenticated';
    } else {
        $error = 'Invalid username or password.';
    }
}


function passwordMatches($username, $password)
{
    $rs = pg_query_params('SELECT password_digest FROM users WHERE username = $1', [$username]);

    $row = pg_fetch_array($rs);

    if (empty($row)) {
        return false;
    }

    return password_verify($password, $row['password_digest']);
}


?>
<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Login</title>
    </head>

    <body>
        <? if ('authenticating' == $state) { ?>
            <form method="post">
                <div>
                    <label>Username</label>
                    <input name="username" type="text" />
                </div>

                <div>
                    <label>Password</label>
                    <input name="password" type="password" />
                </div>

                <button type="submit">Login</button>
            </form>
        <? } else if ('authenticated' == $state) { ?>
            <p>Logged in as <? echo $_SESSION['username']; ?>, On <span style="font-weight: bold;">Page 2!</span></p>
            <p>Go to <a href="index.php"><span style="font-weight: bold;">Page 1!</span></a></p>
        <? } ?>

        <? if (!empty($error)) { ?>
            <p style="color: red;"><?= $error ?></p>
        <? } ?>
    </body>
</html>
