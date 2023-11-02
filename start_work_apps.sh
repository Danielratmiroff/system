#!/bin/bash

# Arrange windows to start work
URLS=("https://www.youtube.com/watch?v=nMfPqeZjc2c&t=10622s&ab_channel=RelaxingWhiteNoise" "https://chat.openai.com/?model=gpt-4")

MESSAGER_APP="slack"
MESSAGER_APP_PATH="/snap/bin/$MESSAGER_APP"

NOTES_APP="simplenote"
NOTES_APP_PATH="/snap/bin/$NOTES_APP"

move_to_main_screen() {
	# Ensure windows are in left monitor
	xdotool keydown Super keydown Shift key Left keyup Shift keyup Super
}

move_to_secondary_screen() {
	# Ensure windows are in right monitor
	xdotool keydown Super keydown Shift key Right keyup Shift keyup Super
}

open_helper_browser() {
	for url in "${URLS[@]}"; do
		brave-browser --new-tab "$url" &
		sleep 1
	done
}

open_helper_browser
sleep 1

# Start apps
$MESSAGER_APP_PATH
sleep 1
move_to_main_screen
sleep 1
xdotool keydown Super key Right keyup Super

sleep 2

$NOTES_APP_PATH
sleep 1
move_to_main_screen
sleep 1
xdotool keydown Super key Left keyup Super
