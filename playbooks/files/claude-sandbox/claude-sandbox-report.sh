#!/bin/bash
# Claude Sandbox Daily Violation Report Generator
# Usage: sudo claude-sandbox-report.sh

LOG_BASE="/var/log/claude-sandbox"
REPORT_DIR="$LOG_BASE/reports"
TODAY=$(date +%Y-%m-%d)
REPORT_FILE="$REPORT_DIR/report-$TODAY.txt"

echo "=== Claude Sandbox Violation Report ===" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== AppArmor Denials (Last 24 Hours) ===" >> "$REPORT_FILE"
journalctl --since "24 hours ago" -k | grep -i 'apparmor.*denied' >> "$REPORT_FILE" 2>/dev/null || echo "No denials found" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== Summary Statistics ===" >> "$REPORT_FILE"
denial_count=$(journalctl --since "24 hours ago" -k | grep -ci 'apparmor.*denied' 2>/dev/null || echo "0")
echo "Total AppArmor denials: $denial_count" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "=== Top Denied Paths ===" >> "$REPORT_FILE"
journalctl --since "24 hours ago" -k | grep -i 'apparmor.*denied' | grep -oP 'name="[^"]*"' | sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE" 2>/dev/null

echo "Report saved to: $REPORT_FILE"
cat "$REPORT_FILE"
