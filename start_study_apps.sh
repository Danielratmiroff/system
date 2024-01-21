#!/bin/bash

# Arrange windows on the desktop for studying

source ~/automation/helpers/arrange_windows_functions.sh

MUSIC_URL="https://www.youtube.com/watch?v=nMfPqeZjc2c&t=10622s&ab_channel=RelaxingWhiteNoise"
OPENAI_URL="https://chat.openai.com/?model=gpt-4"
# create array of urls to open in browser (helper function)
URLS=($MUSIC_URL $OPENAI_URL)

UDEMY_URL="https://www.udemy.com/home/my-courses/learning/"
NOTION_URL="https://www.notion.so/4fff1b5312b846539a7f6b9a4994fb99?v=4bd5a93b35ae4289afc621dc5105d9e9"
K8S_URL="https://kubernetes.io/docs/home/"

pkill brave
sleep 2

# Start browser
open_helper_browser
sleep 2
move_right_monitor
sleep 1
maximize_window

brave-browser --new-window $K8S_URL $NO_OUTPUT
sleep 2
brave-browser --new-tab $UDEMY_URL $NO_OUTPUT
sleep 1
move_left_monitor
sleep 1
move_sideways_right
sleep 1


brave-browser --new-window $NOTION_URL $NO_OUTPUT
sleep 2
move_left_monitor
sleep 1
move_sideways_left
