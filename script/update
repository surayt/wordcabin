#!/bin/bash

git pull origin master
for i in data/*; do (cd $i; git pull; git lfs pull); done
gem install bundler || sudo gem install bundler
bundle install
git submodule foreach 'git fetch origin; \
                       git checkout $(git rev-parse --abbrev-ref HEAD); \
                       git reset --hard origin/$(git rev-parse --abbrev-ref HEAD); \
                       git submodule update --recursive; \
                       git clean -dfx'
rake wordcabin:clean_public_files
rake wordcabin:copy_assets
