require 'fileutils'
require 'nokogiri'
require 'pathname'

MAIN_CONFIG = Pathname('config')+'sinatra_app.rb'
require_relative MAIN_CONFIG

require 'sinatra/activerecord/rake'
# require 'coffee_script'

namespace :db do
  task :load_config do
    require Config.lib+'server.rb'
  end
end

# Legacy files must be copied *before* creating the TOCs
# as otherwise they will not appear in the main TOC then.
task default: [:clean, :copy_legacy_files, :copy_assets, :compile_markdown_files, :build_tocs]

desc "Start the webapp server on port 4567"
task :server do
  `rackup` # Boot Webrick/Mongrel/Thin via Rack 
end

desc "Go through the motions of updating all submodules from their respective repositories"
task :update_submodules do
  command = "git submodule foreach ' \
    git fetch origin; \
    git checkout $(git rev-parse --abbrev-ref HEAD); \
    git reset --hard origin/$(git rev-parse --abbrev-ref HEAD); \
    git submodule update --recursive; \
    git clean -dfx'"
  sh command.gsub(/\n/, '')
end

# https://gist.github.com/vast/381881
desc "Start an interactive console"
task :console, :environment do |t, args|
  ENV['RACK_ENV'] = args[:environment] || 'development'
  sh "pry -I . -r #{MAIN_CONFIG} -r #{Config.lib+'server.rb'} -e 'include SinatraApp; User.connection; ContentFragment.connection;'"
end

desc "Precompile CoffeeScript"
task :precompile_coffeescript do
  sourcedir = (Config.templates+'javascripts').to_s
  Dir.foreach(sourcedir) do |f_in|
    unless f_in == '.' || f_in == '..'
      js = CoffeeScript.compile File.read("#{sourcedir}/#{f_in}")
      open "#{Config.javascript}/#{f_in.gsub('.coffee', '.js')}", 'w' do |f_out|
        puts "Writing #{f_in}"
        f_out.puts js
      end
    end
  end
end  

desc "Copy all assets (images, fonts, etc.) to their appropriate locations to be served by the webapp"
task :copy_assets do
  # TODO: remove next four lines ones legacy conversion complete.
  puts "Deleting and re-linking #{Config.legacy_media}"
  FileUtils.rm_f Config.legacy_media # Only required because 'ln -sf' is f***** up...
  FileUtils.ln_s Config.data, Config.legacy_media
  # TODO: Replace by calling a proper asset pipeline at some point.
  global_assets  = Dir.glob(Config.media+'{images,fonts}')
  puts "Copying #{global_assets.join(', ')}"
  FileUtils.cp_r global_assets, Config.static
  chapter_assets = Dir.glob(Config.data+'chapters'+'*'+'images'+'*')
  Dir.glob('/home/jrs/Projects/wordcabin/data/aop/chapters/*/images/*').each do |p|
    puts "Copying #{p}"
    FileUtils.cp p, Config.static+'images' if FileTest.file?(p)
  end
end

#####################
# ALL DEPRECATED!!! #
#####################

# TODO: Once a proper asset pipeline is installed, check to see if this is still needed.
desc "Remove all automatically compiled or copied files from the cache and public dirs"
task :clean do
  asset_files = Dir.glob(Config.static+'{media,fonts,images,javascripts/*.js,stylesheets/*.{css,map}}') # TODO: Remove 'media' once legacy conversion complete.
  cache_files = Dir.glob(Config.cache+'*')
  (asset_files+cache_files).each do |p|
    puts "Deleting #{p}"
    FileUtils.rm_rf p
  end
end

# Yes, this task duplicates a lot of what's in the build task,
# but that's fine as it is only meant to be here until the
# transition to Markdown input files is complete.
desc "Copy all legacy HTML files to their appropriate location to be served by the webapp"
task :copy_legacy_files do
  %x[find data/aop/chapters/*/texts/?? -type f ! -name '*.md'].split("\n").each do |source|
    unless File.exist?("#{source}.md")
      /.*\/(?<cefr_level>.*)-(?<chapter_name>.*)\/texts\/(?<locale>[a-z][a-z])\/.*/ =~ source
      target_file_name = "#{cefr_level}-#{chapter_name}.html"
      target = Config.cache+'chapters'+locale+target_file_name
      unless File.exist?(target)
        puts "Copying #{source}"
        FileUtils.mkdir_p(target.dirname) 
        File.open(target, 'w') do |f|
          f.puts "<article class='legacy'>"
          f.puts File.read(source)
          f.puts "</article>"
        end
      end
    end
  end
end
