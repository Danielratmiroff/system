#! /bin/bash
set -x

# Script used by cronjobs to push to github automatically

eval "$(ssh-agent -s)"

ssh-add ~/.ssh/github_cron

export SSH_AUTH_SOCK

# Date in format Day-Month-Year
date=$(date +"%Y-%m-%d %T")

message="daily update"
folder="$1" # The folder to push to github

cd $1
yadm add .
yadm commit -m "${message}"
yadm push -u origin master

kill $SSH_AGENT_PID

exit 0
