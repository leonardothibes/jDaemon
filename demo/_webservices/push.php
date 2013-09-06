<?php

if($_SERVER['REQUEST_METHOD'] == 'POST') {
    if(!apc_exists('notification_serial')) {
        apc_store('notification_serial', 0);
    }
    echo apc_fetch('notification_serial');
}