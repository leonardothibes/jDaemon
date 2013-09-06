<?php

if($_SERVER['REQUEST_METHOD'] == 'POST') {
    if(!apc_exists('notification')) {
        apc_store('notification', null);
    }
    echo apc_fetch('notification');
}