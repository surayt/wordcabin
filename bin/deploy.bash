#!/bin/bash

# From http://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change to textbookr installation directory
cd $SCRIPT_DIR/..

function update_project_data()
{
  git fetch
  git log --name-status origin/master --pretty=format:'' > /tmp/deploy.bash.log
}

# Go through list of available projects
for PROJECT in data/*; do
  cd $PROJECT
  update_project_data
done
