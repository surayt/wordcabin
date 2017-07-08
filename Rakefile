require 'fileutils'
require 'nokogumbo'
require 'htmlbeautifier'
require 'htmlcompressor'
require 'pathname'
require 'find'
require 'set'
require 'colorize'

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

  desc "Empty the database of all its data (DANGEROUS, obviously!)"
  task :prune do
    ContentFragment.delete_all
    FileAttachment.delete_all
  end
end

task default: [:clean, :copy_assets, :server]

desc "Start application server on port 4567" # TODO: use port from configuration file!
task :server do
  `rackup` # Boot Webrick/Mongrel/Thin via Rack 
end

# https://gist.github.com/vast/381881
desc "Enter an interactive application console"
task :console, :environment do |t, args|
  ENV['RACK_ENV'] = args[:environment] || 'development'
  sh "pry -I . -r #{MAIN_CONFIG} -r #{Config.lib+'server.rb'} -e 'include SinatraApp; User.connection; ContentFragment.connection; system(\"clear\");'"
end

namespace :wordcabin do
  desc "Give an overview over the project's structure"
  task :list_directories do
    system "tree -d -I 'data|tinymce|bourbon-neat|font-awesome|media|jquery-ujs'"
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

  def process_attached_file(locale, legacy_path)
    extension = legacy_path.split('.').last
    case(extension)
      when 'mp3'
        mime = 'audio/mpeg'
        path = Config.root+'public'+legacy_path.split(':')[1]
      when 'jpg'
        mime = 'image/jpeg'
        path = Config.root+'public'+legacy_path
      else
        return legacy_path
    end; begin
      data = File.binread(path)
      if attachment = FileAttachment.find_by_binary_data(data)
        print '.'.red
      else
        print '.'.white
        attachment = FileAttachment.create(filename: File.basename(path), content_type: mime, binary_data: File.binread(path))
      end
      return attachment.url_path
    rescue Errno::ENOENT
      return "NO SUCH FILE (was: #{legacy_path})"
    end
  end

  def clean_html(locale, input)
    doc = Nokogiri::HTML.fragment(input) {|config| config.noblanks}
    # return input
    %w{style width height cellpadding cellspacing border dir}.each {|a| doc.css('*').remove_attr(a)}
    doc.css('[lang^="EN-US"]').each {|n| n.remove_attribute('lang')}
    doc.css('[lang]').each {|n| n.set_attribute('lang', n.get_attribute('lang').downcase)}
    %w{href src}.each {|a|
      doc.css("[#{a}]").each {|n|
        path = n.get_attribute(a)
        n.set_attribute(a, process_attached_file(locale, path)) if path.include? '.' # Otherwise it's not a file...
        %w{class target}.each {|trash| n.remove_attribute(trash)}
      }
    }
    nodes = doc.css('span'); nodes.each {|n| n.replace(n.content) unless n.get_attribute('lang')}
    doc.css('*').each {|n| n.remove if n.content.blank?; n.remove if n.content.strip.empty?}
    doc.css('p[align]').each {|n| n.parent.set_attribute('align', n.get_attribute('align')) if n.parent.name == 'td'; n.replace(n.children)}
    3.times {doc.css('div[align^="center"] table').each {|n| n.parent.replace(n.parent.children) if n.name == 'table' && n.parent.name == 'div'}}
    doc.css('td p').each {|n| n.replace(n.content)}
    doc.css('*').xpath('text()').each {|n| n.content = n.content.gsub(/\u00a0/, '').gsub(/^\s+|\s+$|\s+(?=\s)/, '')}
    HtmlBeautifier.beautify(doc.to_html, indent: '  ') # HtmlCompressor::Compressor.new.compress(noko.to_xhtml)
  end

  desc "Read in legacy HTML content files, rid them of extraneous markup and save them as content_fragments"
  task :import_aop_data, [:locale] do |t, args|
    unless args[:locale] && args[:locale].length == 2
      puts "\n  One argument required: locale to be imported.\n" +
           "  ATTENTION: All ContentFragments of that locale\n"  +
           "  will be deleted!\n\n"                              +
           "  You may specify two asterisks (**) for all locales.\n\n"
      exit
    end
    ContentFragment.where(locale: args[:locale]).delete_all
    locales = Set.new
    books = Set.new
    chapter_top_level = {}
    locale_to_process = args[:locale] == '**' ? '*' : args[:locale]
    Dir[Config.data+'chapters'+'*'+'texts'+locale_to_process+'*'].sort.each do |path|
      # Yes, the next 5 lines could just be a regex, but c'mon, this is temporary code, leave me alone!
      lmnts = path.split('/')
      idx = lmnts.index('chapters')
      info = lmnts[idx+1, lmnts.length]; info.delete('texts')
      # See, same result as what we'd get from a regex :). And results rarely stink if they're correct.
      locale, level, chapter_designator, chapter_name = [info[1], info[0].split('-')[0], info[0].split('-')[1], info[2]]
      # The real work begins. It's ugly. Noone cares. This is temporary code, remember?
      book_name = "#{I18n.t(:level)} #{level.upcase}"
      unless (locales.include?(locale) && books.include?(level))
        puts "Creating book".green
        ContentFragment.create(locale: locale, book: book_name) # The top-level element and jump-in point.
      end
      locales << locale; books << level
      book = "#{locale} #{level}"
      chapter_top_level[book] ? chapter_top_level[book] += 1 : chapter_top_level[book] = (0+1)
      # One chapter; belongs to the top-level element by having the same 'book' field value.
      print "Creating chapter"
      c = ContentFragment.new(
        locale: locale,
        book: book_name,
        chapter: chapter_top_level[book].to_s,
        heading: "#{chapter_name} (#{chapter_designator || '-'})",
        html: clean_html(locale, File.read(path)))
      puts # Newline...
      # Wrapping it up.
      if c.save
        puts 'Success: '+info.join('/').ljust(50, ' ')+"->\t"+([c.locale, c.book, c.chapter, c.chapter_padded].join("\t"))+"\n"
      else
        puts c.errors.inspect.red
      end
    end
  end

  desc "Remove all automatically compiled or copied files from the static files directory"
  task :clean_public_files do
    # TODO: Remove 'media' once legacy conversion complete.
    Dir.glob(Config.static_files+'{fonts,images,media}').each do |p|
      puts "Deleting #{p}"
      FileUtils.rm_rf p
    end
  end
end
