#! /bin/bash
set -x

export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh

# Date in format Day-Month-Year
date=$(date +"%Y-%m-%d %T")

# Commit message
message="daily update"

cd /home/daniel/ansible/
git add .
git commit -m "${message}"
git push -u origin master
