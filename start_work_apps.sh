#!/bin/bash

# Arrange windows to start work
#
MESSAGER_APP="slack"
MESSAGER_APP_PATH="/snap/bin/$MESSAGER_APP"

NOTES_APP="simplenote"
NOTES_APP_PATH="/snap/bin/$NOTES_APP"

move_to_main_screen() {
	# Ensure windows are in left monitor
	xdotool keydown Super keydown Shift key Left keyup Shift keyup Super
}

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
