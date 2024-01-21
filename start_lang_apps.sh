#!/bin/bash

# Arrange windows on the desktop for studying languages

source ~/automation/helpers/arrange_windows_functions.sh

MUSIC_URL="https://www.youtube.com/watch?v=nMfPqeZjc2c&t=10622s&ab_channel=RelaxingWhiteNoise"
OPENAI_URL="https://chat.openai.com/?model=gpt-4"
# create array of urls to open in browser (helper function)
URLS=($MUSIC_URL $OPENAI_URL)

TRANSLATE_URL="https://translate.google.com/?hl=en&sl=de&tl=es&t&op=translate"

pkill brave
sleep 2

# Open study materials
open_helper_browser
sleep 2
move_left_monitor
sleep 1
move_sideways_left
sleep 1

# OPEN TRANSLATE
brave-browser --new-window $TRANSLATE_URL $NO_OUTPUT
sleep 2
move_left_monitor
sleep 1
move_sideways_right
