#!/bin/bash

# From http://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change to textbookr installation directory
cd $SCRIPT_DIR/..

function update_project_data()
{
  git fetch origin master
  MD_FILES=$(git log --name-status origin/master... --pretty=format:'' | grep -v -e '^$' | grep -v -e '^D' | grep '\.md' | ruby -ne 'puts $_.gsub(/[A-Z]\W+/, "")')
  # Deal with file names containing spaces
  SAVEIFS=$IFS
  IFS=$(echo -en "\n\b")
  # Go through list of Markdown files
  RAKE_OPTS=$(for FILE in $MD_FILES; do echo "$FILE" | ruby -ne '/.*\/(?<cefr_level>.*)-(?<chapter_name>.*)\/texts\/(?<locale>[a-z][a-z])\/.*/ =~ $_; if (cefr_level || chapter_name || locale).nil?; /.*\/(?<name>.*)\/texts\/(?<locale>[a-z][a-z])\/.*/ =~ $_; cefr_level = chapter_name = name; end; puts [locale,cefr_level,chapter_name].join(",")'; done)
  # Finally pull, then run Rake to compile each of the changed files
  git pull origin master
  set -x # Echo each command
  for OPTS in $RAKE_OPTS; do rake compile_markdown_file[$OPTS]; done
}

# Go through list of available projects
for PROJECT in data/*; do
  cd $PROJECT
  update_project_data
done
