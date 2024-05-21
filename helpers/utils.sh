#!/bin/bash

# Utility functions 

NO_OUTPUT=</dev/null &>/dev/null &

open_helper_browser() {
	for url in "${URLS[@]}"; do
		brave-browser --new-tab "$url" $NO_OUTPUT
		sleep 1
	done
}
