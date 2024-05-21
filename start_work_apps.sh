#!/bin/bash

# This script is used to start work-related applications 

# The following applications are started:
# - Brave 
# - Slack

source ~/automation/helpers/utils.sh
source ~/automation/helpers/arrange_windows_functions.sh

# Start apps
brave-browser $NO_OUTPUT
~/snap/bin/slack $NO_OUTPUT

# Start apps on second desktop
sleep 2
move_to_desktop_on_right
fish -c 'android_studio start' & $NO_OUTPUT

# Return to desktop
sleep 3
move_to_desktop_on_left

