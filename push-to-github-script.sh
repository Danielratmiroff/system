#! /bin/bash
set -x

export GIT_SSH_COMMAND="ssh -i /home/daniel/.ssh/github_rsa.pub"

# Date in format Day-Month-Year
date=$(date +"%Y-%m-%d %T")

# Commit message
message="daily update"

cd /home/daniel/ansible/
git add .
git commit -m "${message}"
git push -u origin master
