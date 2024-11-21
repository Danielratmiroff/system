#! /bin/bash
set -x

# Script used by cronjobs to push to github automatically

if [ -z "$2" ]; then
    echo "Usage: $0 <folder> <ssh-key-path>"
    exit 1
fi

ssh_key_path="$2"

eval "$(ssh-agent -s)"

ssh-add "$ssh_key_path"

export SSH_AUTH_SOCK

# Date in format Day-Month-Year
date=$(date +"%Y-%m-%d %T")

message="daily update"
folder="$1" # The folder to push to github

cd "$folder" || exit
git add .
git commit -m "${message}"
git push -u origin master

kill $SSH_AGENT_PID

exit 0
