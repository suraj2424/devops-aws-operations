#!/bin/bash

echo "----------------------------------------"
echo "System Report - $(date)"
echo "----------------------------------------"

echo "Current Date & Time: $(date)"
echo "Uptime:"
uptime -p

echo "CPU Usage (%):"
top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}'

echo "Memory Usage (%):"
free | grep Mem | awk '{print ($3/$2)*100 "%"}'

echo "Disk Usage (%):"
df -h / | awk 'NR==2 {print $5}'

echo "Top 3 CPU Consuming Processes:"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 4

echo ""
