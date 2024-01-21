#!/bin/bash

# Helper functions for arranging windows on the desktop
# and opening browser tabs


# Helper functions to move windows on monitors
move_left_monitor(){
	xdotool key Super+Shift+Left; xdotool key Escape
}

move_right_monitor(){
	xdotool key Super+Shift+Right; xdotool key Escape
}

# Helper functions to move windows sideways
move_sideways_left() {
	xdotool key Super+Left; xdotool key Escape
}

move_sideways_right() {
	xdotool key Super+Right; xdotool key Escape
}

# Helper function to modify window size
maximize_window() {
    xdotool key Super+Up; xdotool key Escape
}

# Other stuff
NO_OUTPUT=</dev/null &>/dev/null &

open_helper_browser() {
	for url in "${URLS[@]}"; do
		brave-browser --new-tab "$url" $NO_OUTPUT
		sleep 1
	done
}
