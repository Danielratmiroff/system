#!/bin/bash
# Claude Sandbox Real-Time Violation Monitor
# Usage: sudo claude-sandbox-monitor.sh

LOG_BASE="/var/log/claude-sandbox"
VIOLATIONS_LOG="$LOG_BASE/violations/realtime-$(date +%Y%m%d).log"

echo "Starting Claude Sandbox Violation Monitor..."
echo "Logging AppArmor denials to: $VIOLATIONS_LOG"
echo "Press Ctrl+C to stop"
echo ""

# Monitor journald for AppArmor denials related to bubblewrap
journalctl -f -k | grep --line-buffered -i 'apparmor.*denied\|bwrap' | while read -r line; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $line" | tee -a "$VIOLATIONS_LOG"
done
