#!/bin/bash

# Arrange windows on the desktop for studying
UDEMY_URL="https://www.udemy.com/home/my-courses/learning/"
NOTION_URL="https://notion.so"

UDEMY_WINDOW_TITLE="udemy"
NOTION_WINDOW_TITLE="notebook"

move_to_main_screen() {
	# Ensure windows are in left monitor
	xdotool keydown Super keydown Shift key Left keyup Shift keyup Super
}

# Kill brave as we need to focus
pkill brave

# Open study materials
brave-browser --new-window $UDEMY_URL &
sleep 2
brave-browser --new-window $NOTION_URL &
sleep 2

# Arrange windows

udemy_id=$(xdotool search --name $UDEMY_WINDOW_TITLE)
notion_id=$(xdotool search --name $NOTION_WINDOW_TITLE)

xdotool windowfocus $udemy_id
sleep 1
move_to_main_screen
sleep 1
xdotool keydown Super key Left keyup Super

sleep 3

xdotool windowfocus $notion_id
sleep 1
move_to_main_screen
sleep 1
xdotool keydown Super key Right keyup Super
