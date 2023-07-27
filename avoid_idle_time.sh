#!/bin/bash

minutes=0
hours=0

while true; do
	xdotool key asterisk
	sleep 60

	minutes=$((minutes + 1))

	if [ $minutes -eq 60 ]; then
		hours=$((hours + 1))
		minutes=0
	fi

	echo " Time: $hours:$minutes"
done
