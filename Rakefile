require 'fileutils'
require 'nokogumbo'
require 'htmlbeautifier'
require 'htmlcompressor'
require 'pathname'
require 'find'
require 'set'
require 'securerandom'
require 'colorize'

MAIN_CONFIG = Pathname('config')+'config.rb'
require_relative MAIN_CONFIG

require 'sinatra/activerecord/rake'
require_relative 'lib/server'
include SinatraApp

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.load_path = Dir[Config.translations+'*.yml']
I18n.backend.load_translations

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = 'lib/tests/*.rb'
  t.warning = false
end

# What gets run when no arguments are specified
task default: [:server]

# TODO: Figure out how to use different database for testing
# (lib/server.rb) because right now testing will meddle with
# the production database.
Rake::Task['test'].clear
task :test do
  puts 'Testing is disabled. Please see Rakefile comment for more information.'
end

# Stolen from https://github.com/rails/rails/blob/master/railties/lib/rails/tasks/misc.rake
desc "Generate a cryptographically secure secret key to use as a cookie session secret"
task :secret do
  puts SecureRandom.hex(64)
end

desc "Start application server on configured port"
task :server do
  watchlist = %w{
    config db
    javascripts/application javascripts/tinymce_plugins
    lib locales
    stylesheets/article stylesheets/features stylesheets/modules
    templates
  }
  # Boot Puma via Rack, keep reloading via rerun.
  # The latter won't work using backticks, only
  # using system() which forks off.
  system("rerun --dir #{watchlist.join ','} --clear rackup")
end

# https://gist.github.com/vast/381881
desc "Enter an interactive application console"
task :console, :environment do |t, args|
  ENV['RACK_ENV'] = args[:environment] || 'development'
  sh "pry -I . -r #{MAIN_CONFIG} -r #{Config.lib+'server.rb'} -e 'include SinatraApp; User.connection; ContentFragment.connection; system(\"clear\");'"
end

namespace :db do
  task :load_config do
    require Config.lib+'server.rb'
  end

  desc "Empty the database of all its data (DANGEROUS, obviously!)"
  task :prune do
    ContentFragment.delete_all
    FileAttachment.delete_all
  end
end   

namespace :wordcabin do
  desc "Update to the latest version from git, performing all the necessary steps"
  task :update do
    # Not done inside of here so that the script can be run on its
    # own, i.e. via a cron job, etc. and not fail even when rake
    # would not work for some reason.
    system "sh script/update"
  end

  desc "Give an overview over the project's structure"
  task :list_directories do
    system "tree -d -I 'data|tinymce|bourbon|neat|bitters|font-awesome|media|jquery'"
  end
end
