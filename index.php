<!DOCTYPE HTML>
<html lang="pt-BR">

<head>
    <?php $title = 'jDaemon in Action'; ?>
    <title><?=$title?></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>

<body style="text-align: center;">

<h1><?=$title?></h1>

<ul>
    <?php

    define('DEMO_PATH', realpath(dirname(__FILE__) . '/demo'));
    $directory = new DirectoryIterator(DEMO_PATH);

    foreach ($directory as $demo) {
        if (!$demo->isDot() and $demo != '_webservices') {
            echo sprintf('<li><a href="/demo/%s">%s</a></li>', $demo, $demo);
        }
    }
    ?>
</ul>

</body>
</html>