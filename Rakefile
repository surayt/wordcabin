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

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = 'lib/tests/*.rb'
  t.warning = false
end

task default: ["wordcabin:clean_public_files", "wordcabin:copy_assets", "server"]

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

namespace :db do
  task :load_config do
    require Config.lib+'server.rb'
  end

  desc "Empty the database of all its data (DANGEROUS, obviously!)"
  task :prune do
    ContentFragment.delete_all
    FileAttachment.delete_all
  end
  
  def interpret_path(path)
    # Yes, the next 5 lines could just be a regex, but c'mon, this is temporary code, leave me alone!
    lmnts = path.split('/')
    idx = lmnts.index('chapters')
    info = lmnts[idx+1, lmnts.length]; info.delete('texts')
    # See, same result as what we'd get from a regex :). And results rarely stink if they're correct.
    [info[1], info[0].split('-')[0], info[0].split('-')[1], info[2]]
  end
  
  def import_file(path, locale, book_name, chapter_designator, chapter_name, chapter_number)
    print "Creating chapter"
    html = clean_html(locale, File.read(path))
    heading = extract_heading(html, "#{chapter_name} (#{chapter_designator || '-'})")
    # A chapter belongs to the top-level element by having the same 'book' field value. There are no formal relationships!
    c = ContentFragment.new(locale: locale, book: book_name, chapter: chapter_number, heading: heading, html: html)
    puts # Newline...
    # Wrapping it up.
    if c.save
      puts "Success:\t#{([c.locale, c.book, c.chapter, c.chapter_padded].join("\t"))}\t<-\t#{path}"
    else
      puts "Chapter: #{c.errors.full_messages.join("\n").to_s.red}"
    end
  end
  
  def process_attached_file(locale, legacy_path)
    extension = legacy_path.split('.').last
    case(extension)
      when 'mp3'
        mime = 'audio/mpeg'
        if legacy_path.include? ':'
          path = Config.root+'public'+legacy_path.split(':')[1]
        else
          chapter_dir = legacy_path.split('/')[1]
          audiofile_name = legacy_path.split('/')[2]
          path = Config.root+'public'+'media'+'chapters'+chapter_dir+'audios'+audiofile_name
        end
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
    %w{width height cellpadding cellspacing border dir frame rules valign}.each {|a| doc.css('*').remove_attr(a)}
    doc.css('[align]').each {|n| n.set_attribute('style', "text-align: #{n.get_attribute('align')}"); n.remove_attribute('align')}
    doc.css('[class^="soundlink"]').remove_attr('class')
    
    ['[style*="color: red;"]', '[style*="color:red;"]'].each {|s|
      doc.css(s).each {|n|
        n.set_attribute('class', [n.get_attribute('class'), 'highlight'].join(' ').strip)
      }
    }
    
    doc.css('*').remove_attr('style')
    
    # TODO: re-enable once TinyMCE agrees to this, too.
    # doc.css('em').each {|n| n.name = 'span'; n.set_attribute('style', 'font-style: italic;')}
    # doc.css('strong').each {|n| n.name = 'span'; n.set_attribute('style', 'font-weight: bold;')}
    
    [:unmodified, :lowercase, :uppercase].each do |lettercase|
      ['en-US', 'en-GB', 'ar', 'ar-SA', 'nl', 'es', 'no-BOK'].each do |lang|
        case lettercase
          when :lowercase
            lang.downcase!
          when :uppercase
            lang.upcase!
        end
        doc.css("[lang^=\"#{lang}\"]").each {|n| n.remove_attribute('lang')}
      end
    end
        
    doc.css('[lang]').each {|n|
      updated_lang = n.get_attribute('lang').downcase
      if n.name == 'span'
        if n.element_children.any?
          n.children.first.set_attribute('lang', updated_lang)
        else
          parent = n.parent
          loop do
            parent.set_attribute('lang', updated_lang)
            if parent.name == 'span'
              parent = parent.parent
            else
              break
            end
          end
        end
      else
        n.set_attribute('lang', updated_lang)
      end
    }
    doc.css('span').each {|n| n.set_attribute('lang', n.get_attribute('lang').downcase) if n.get_attribute('lang')}
    doc.css('span').each {|n| n.replace(n.children) if n.attributes.empty? || (n.attributes.length == 1 && (n.get_attribute('lang') || '').downcase == 'syr')}
    
    %w{href src}.each {|a|
      doc.css("[#{a}]").each {|n|
        path = n.get_attribute(a)
        new_href = process_attached_file(locale, path)
        n.set_attribute(a, new_href) if path.include? '.' # Otherwise it's not a file...
        n.remove_attribute('target')
        n.set_attribute('class', [n.get_attribute('class'), 'file'].join(' ').strip) if new_href != path
      }
    }
    
    doc.css('*').each {|n| n.remove if n.content.blank?; n.remove if n.content.strip.empty?}
    
    doc.css('p[align]').each {|n| n.parent.set_attribute('align', n.get_attribute('align')) if n.parent.name == 'td'; n.replace(n.children)}
    3.times {doc.css('div[align^="center"] table').each {|n| n.parent.replace(n.parent.children) if n.name == 'table' && n.parent.name == 'div'}}
    doc.css('td p').each {|n| n.replace(n.children)}
    # doc.css('div[class^="WordSection1"]').each {|n| n.replace(n.children)}
    # doc.css('div[id^="_mcePaste"]').each {|n| n.name = 'p'; n.remove_attribute('id')}
    doc.css('*').xpath('text()').each {|n| n.content = n.content.gsub(/\u00a0/, ' ').gsub(/^\s+|\s+$|\s+(?=\s)/, ' ')}
    doc.css('div').each {|n| n.replace(n.children)}
    
    doc.css('*').xpath('text()').each {|n|
      if n.content.match /\p{Syriac}/
        # n.parent.set_attribute('lang', 'syr')
        marked = false
        # cdepth = 1
        parent = n.parent
        loop do
          marked = true if parent && (parent.get_attribute('lang') || '') == 'syr'
          if marked
            break
          else
            if parent
              parent = parent.parent
            else
              break
            end
          end
          # cdepth +=1 ; break if cdepth > 3
        end
        n.parent.set_attribute('lang', 'syr') unless marked
      end
    }
    
    HtmlBeautifier.beautify(doc.to_html, indent: '  ') # HtmlCompressor::Compressor.new.compress(noko.to_xhtml)
  end
  
  def extract_heading(input, fallback)
    doc = Nokogiri::HTML.fragment(input)
    out = Nokogiri::HTML.fragment('')
    table = doc.css('table').first
    if table && table.css('tr').length == 1 && table.css('td').length.between?(1, 4)
      Nokogiri::HTML::Builder.with(out) {|n| n.table {n.tr {table.css('td').each {|td| n.td td.content}}}}
    else
      Nokogiri::HTML::Builder.with(out) {|n| n.table {n.tr {n.td fallback}}}
    end
    out.to_html
  end
  
  desc "Read in legacy HTML content files, rid them of extraneous markup and save them as content_fragments"
  task :import_aop_data, [:locale_or_file] do |t, args|
    locale_to_import = file_to_import = nil
    begin
      if args[:locale_or_file] == '**'
        locale_to_import = '*'
      elsif args[:locale_or_file].length == 2
        locale_to_import = args[:locale_or_file]
      elsif args[:locale_or_file].length  > 2
        file_to_import   = args[:locale_or_file]
      end
    rescue
      puts "\n  One argument required: locale to be imported.\n"       +
           "  ATTENTION: All ContentFragments in that locale\n"        +
           "  will be deleted!\n\n"                                    +
           "  You may specify two asterisks (**) for all locales.\n\n" +
           "  Should you wish to import a specific file, please\n"    +
           "  provide its full path.\n\n"
      exit
    end; if locale_to_import
      locales = Set.new
      books = Set.new
      chapter_top_level = {}
      # The real work begins. It's ugly. Noone cares. This is temporary code, remember?
      Dir[Config.data+'chapters'+'*'+'texts'+locale_to_import+'*'].sort.each do |path|
        locale, level, chapter_designator, chapter_name = interpret_path(path)
        unless locales.include? locale
          puts "Deleting content_fragments in locale [#{locale}]".red
          ContentFragment.where(locale: locale).delete_all
        end
        locales << locale
        books   << level
        book     = "#{locale} #{level}"
        chapter_top_level[book] ? chapter_top_level[book] += 1 : chapter_top_level[book] = (0+1)
        chapter_number = chapter_top_level[book].to_s
        book_name = "#{I18n.t(:level)} #{level.upcase}"
        unless ContentFragment.book(locale, book_name).any?
          puts "Creating book (#{locale}/#{level})".green
          ContentFragment.create(locale: locale, book: book_name) # The top-level element and jump-in point.
        end
        import_file(path, locale, book_name, chapter_designator, chapter_name, chapter_number)
      end
    elsif file_to_import
      path = Pathname(file_to_import).to_s
      locale, level, chapter_designator, chapter_name = interpret_path(path)
      book_name = "#{I18n.t(:level)} #{level.upcase}"
      puts "Warning: not deleting any content_fragments; chapter is going to be the last in its locale/book!".yellow
      last_chapter = ContentFragment.where(locale: locale, book: book_name).non_empty_chapters
      chapter_number = last_chapter.any? ? last_chapter.last.chapter.to_i + 1 : 1
      unless ContentFragment.book(locale, book_name).any?
        puts "Warning: creating new book for chapter to reside in!".yellow
        book = ContentFragment.create(locale: locale, book: book_name)
        puts "Book: #{book.errors.full_messages.join("\n").to_s.red}\n(#{book.inspect})" if book.errors.any?
      end
      import_file(path, locale, book_name, chapter_designator, chapter_name, chapter_number)
    else
      puts "Error: I couldn't find the locale(s) or file you specified!"
    end
  end
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
    # TODO: remove next four lines once legacy conversion complete.
    puts "Deleting and re-linking #{Config.legacy_media}"
    FileUtils.rm_f Config.legacy_media # Only required because 'ln -sf' is f***** up...
    FileUtils.ln_s Config.data, Config.legacy_media
    # TODO: Configure Sprockets to access this path directly?
    global_assets  = Dir.glob(Config.media+'{images,fonts}')
    puts "Copying #{global_assets.join(', ')}"
    FileUtils.cp_r global_assets, Config.static_files
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
