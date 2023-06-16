#! /bin/bash
set -x

export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh

# Date in format Day-Month-Year
date=$(date +"%Y-%m-%d %T")

# Commit message
message="daily update"
folder="$1"

cd $1
git add .
git commit -m "${message}"
git push -u origin master
exit 0
