#!/bin/bash

USER_SHELL=$(getent passwd $LOGNAME | cut -d: -f7)

COMMAND_TO_RUN="neofetch"

$USER_SHELL -c "$COMMAND_TO_RUN"
