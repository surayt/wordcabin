require 'fileutils'
require 'nokogiri'
require 'sanitize'
require 'pathname'
require 'find'
require 'set'

MAIN_CONFIG = Pathname('config')+'config.rb'
require_relative MAIN_CONFIG

require 'sinatra/activerecord/rake'
require_relative 'lib/server'
include SinatraApp
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.load_path = Dir[Config.translations+'*.yml']
I18n.backend.load_translations

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

desc "Read in legacy HTML content files, rid them of extraneous markup and save them as content_fragments"
task :import_aop_data, [:locale] do |t, args|
  unless args[:locale] && args[:locale].length == 2
    puts "\n  One argument required: locale to be imported.\n" +
         "  ATTENTION: All ContentFragments of that locale\n"  +
         "  will be deleted!\n\n"
    exit
  end
  # For cleaning up the old data's messed up HTML
  # em span strong
  Sanitize::Config::AOP_DATA = {
    elements: %w[a audio b bdi bdo br caption cite code col colgroup dd del details dfn div dl dt figcaption figure h1 h2 h3 h4 h5 h6 hr i img li ol p pre q s sub summary sup table tbody td tfoot th thead tr track u ul video],
    attributes: {
      'a': %w[href title class id],
      'audio': %w[src],
      'span': %w[class id]
    },
    remove_contents: false}
  ContentFragment.where(locale: args[:locale]).delete_all
  locales = Set.new
  books = Set.new
  chapter_top_level = {}
  Dir[Config.data+'chapters'+'*'+'texts'+args[:locale]+'*'].sort.each do |path|
    # Yes, the next 5 lines could just be a regex, but c'mon, this is temporary code, leave me alone!
    lmnts = path.split('/')
    idx = lmnts.index('chapters')
    info = lmnts[idx+1, lmnts.length]; info.delete('texts')
    # See, same result as what we'd get from a regex :). And results rarely stink if they're correct.
    locale, level, chapter_designator, chapter_name = [info[1], info[0].split('-')[0], info[0].split('-')[1], info[2]]
    # The real work begins. It's ugly. Noone cares. This is temporary code, remember?
    book_name = "#{I18n.t(:level)} #{level.upcase}"
    if !locales.include?(locale) || !books.include?(level)
      ContentFragment.create(locale: locale, book: book_name) # The top-level element and jump-in point.
    end
    locales << locale; books << level
    book = "#{locale} #{level}"
    chapter_top_level[book] ? chapter_top_level[book] += 1 : chapter_top_level[book] = (0+1)
    # One chapter; belongs to the top-level element through having the same 'book' field value.
    c = ContentFragment.new(
      locale: locale,
      book: book_name,
      chapter: chapter_top_level[book].to_s,
      heading: "#{chapter_name} (#{chapter_designator || '-'})",
      html: Sanitize.fragment(File.read(path), Sanitize::Config::AOP_DATA))
    # Wrapping it up.
    if c.save
      puts (info.join('/')+':').ljust(50, ' ')+([c.locale, c.book, c.chapter].join("\t"))+"\n"
    else
      puts c.errors.inspect
    end
  end
end

desc "Empty the database of all content fragments (DANGEROUS!)"
task :prone_database do
  ContentFragment.delete_all
end

desc "Remove all automatically compiled or copied files from the static files directory"
task :clean_public_files do
  # TODO: Remove 'media' once legacy conversion complete.
  Dir.glob(Config.static_files+'{fonts,images,media}').each do |p|
    puts "Deleting #{p}"
    FileUtils.rm_rf p
  end
end
