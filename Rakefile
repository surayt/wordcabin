require 'fileutils'
require 'nokogiri'
require 'pathname'
MAIN_CONFIG = Pathname('config')+'config.rb'
require_relative MAIN_CONFIG
require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require Config.lib+'server.rb'
  end
end

task default: [:clean, :copy_assets, :server]

desc "Start application server on port 4567" # TODO: use port from configuration file!
task :server do
  `rackup` # Boot Webrick/Mongrel/Thin via Rack 
end

desc "Give an overview over the project's structure"
task :list_directories do
  system "tree -d -I 'data|tinymce|bourbon-neat|font-awesome|media|jquery-ujs'"
end

# https://gist.github.com/vast/381881
desc "Enter an interactive application console"
task :console, :environment do |t, args|
  ENV['RACK_ENV'] = args[:environment] || 'development'
  sh "pry -I . -r #{MAIN_CONFIG} -r #{Config.lib+'server.rb'} -e 'include SinatraApp; User.connection; ContentFragment.connection; system(\"clear\");'"
end

desc "Update all git submodules (use carefully)"
task :update_submodules do
  command = "git submodule foreach ' \
    git fetch origin; \
    git checkout $(git rev-parse --abbrev-ref HEAD); \
    git reset --hard origin/$(git rev-parse --abbrev-ref HEAD); \
    git submodule update --recursive; \
    git clean -dfx'"
  sh command.gsub(/\n/, '')
end

desc "Copy all required files from data/ to public/"
task :copy_assets do
  # TODO: remove next four lines ones legacy conversion complete.
  puts "Deleting and re-linking #{Config.legacy_media}"
  FileUtils.rm_f Config.legacy_media # Only required because 'ln -sf' is f***** up...
  FileUtils.ln_s Config.data, Config.legacy_media
  # TODO: Replace by calling a proper asset pipeline at some point.
  global_assets  = Dir.glob(Config.media+'{images,fonts}')
  puts "Copying #{global_assets.join(', ')}"
  FileUtils.cp_r global_assets, Config.static_files
  chapter_assets = Dir.glob(Config.data+'chapters'+'*'+'images'+'*')
  Dir.glob('/home/jrs/Projects/wordcabin/data/aop/chapters/*/images/*').each do |p|
    puts "Copying #{p}"
    FileUtils.cp p, Config.static_files+'images' if FileTest.file?(p)
  end
end

desc "Remove all automatically compiled or copied files from the static files directory"
task :clean do
  # TODO: Remove 'media' once legacy conversion complete.
  Dir.glob(Config.static_files+'{fonts,images,media}').each do |p|
    puts "Deleting #{p}"
    FileUtils.rm_rf p
  end
end
