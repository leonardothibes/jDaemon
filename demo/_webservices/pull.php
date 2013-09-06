<?php

if($_SERVER['REQUEST_METHOD'] == 'POST' and isset($_POST['notification'])) {
    if(!apc_exists('notification_serial')) {
        apc_store('notification_serial', 0);
    }
    apc_store('notification', $_POST['notification']);
    $serial = apc_fetch('notification_serial');
    apc_store('notification_serial', ++$serial);
}