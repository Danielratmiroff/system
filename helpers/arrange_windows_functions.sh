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

# Helper function to switch desktop
move_to_desktop_on_right(){
	xdotool key Alt+Down;
}

move_to_desktop_on_left(){
	xdotool key Alt+Up;
}
