#!/bin/bash

# Arrange windows on the desktop for studying
URLS=("https://www.youtube.com/watch?v=nMfPqeZjc2c&t=10622s&ab_channel=RelaxingWhiteNoise" "https://chat.openai.com/?model=gpt-4")

UDEMY_URL="https://www.udemy.com/home/my-courses/learning/"
NOTION_URL="https://www.notion.so/4fff1b5312b846539a7f6b9a4994fb99?v=4bd5a93b35ae4289afc621dc5105d9e9"
K8S_URL="https://kubernetes.io/docs/home/"

UDEMY_WINDOW_TITLE="udemy"
NOTION_WINDOW_TITLE="Studies"
HELPERS_URL="ChatGPT"

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

	move_to_secondary_screen
	sleep 1
	xdotool keydown Super key Up keyup Super
}

# Kill brave as we need to focus
pkill brave
sleep 1

# Open study materials
open_helper_browser
sleep 1

brave-browser --new-window $UDEMY_URL &
brave-browser --new-window $NOTION_URL &
sleep 3

### Arrange windows
udemy_id=$(xdotool search --name $UDEMY_WINDOW_TITLE)
notion_id=$(xdotool search --name $NOTION_WINDOW_TITLE)

# udemy on left side of screen
xdotool windowfocus $udemy_id
brave-browser --new-tab $K8S_URL &
move_to_main_screen
sleep 1
xdotool keydown Super key Left keyup Super

sleep 1

# notion on right side of screen
xdotool windowfocus $notion_id
echo $notion_id
move_to_main_screen
sleep 1
xdotool keydown Super key Right keyup Super
