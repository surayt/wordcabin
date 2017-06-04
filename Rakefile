require 'fileutils'
require 'nokogiri'
require_relative 'config/app.rb'
require_relative Config.lib_path+'parser.rb'
require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require Config.lib_path+'server.rb'
  end
end

desc "Start the webapp server on port 4567"
task :server do
  sh "ruby config/rack.rb" # FIXME: why does rerun not work anymore?
end

# https://gist.github.com/vast/381881
desc "Start an interactive console"
task :console, :environment do |t, args|
  ENV['RACK_ENV'] = args[:environment] || 'development'
  sh "pry -I . -r config/app.rb -r #{Config.lib_path+'server.rb'} -e 'include Textbookr; User.connection;'"
end

=begin
# Legacy files must be copied *before* creating the TOCs
# as otherwise they will not appear in the main TOC then.
task default: [:clean, :copy_legacy_files, :copy_assets, :compile_markdown_files, :build_tocs]

# TODO: Once a proper asset pipeline is installed, check to see if this is still needed.
desc "Remove all automatically compiled or copied files from the cache and public dirs"
task :clean do
  asset_files = Dir.glob(Config.public_path+'{media,fonts,images,stylesheets/*.{css,map}}') # TODO: Remove 'media' once legacy conversion complete.
  cache_files = Dir.glob(Config.cache_path+'*')
  (asset_files+cache_files).each do |p|
    puts "Deleting #{p}"
    FileUtils.rm_rf p
  end
end

desc "Compile the Markdown file(s) specified by the arguments into HTML"
task :compile_markdown_file, [:locale, :cefr_level, :chapter_name] do |t, args|
  unless args.to_a.size == 3
    fail "You must supply locale, cefr_level and chapter_name"
  end
  Textbookr::Parser.parse(args) # knows what file to write to based on the args
end

desc "Compile all Markdown files into HTML"
task :compile_markdown_files do
  # Anything with 'test' in its path is excluded as those files could be rather large...
  %x{find #{Config.data_path} -type f ! -path '*test*' -name '*.md'}.split("\n").each do |source|
    # By way of '=~' and named matching groups, Ruby directly creates a local variable for each group
    /.*\/(?<cefr_level>.*)-(?<chapter_name>.*)\/texts\/(?<locale>[a-z][a-z])\/.*/ =~ source
    # This is only to be able to have a 'test' folder, at the moment
    if (cefr_level || chapter_name || locale).nil?
      /.*\/(?<name>.*)\/texts\/(?<locale>[a-z][a-z])\/.*/ =~ source
      cefr_level = chapter_name = name
    end
    # File by file...
    Rake::Task[:compile_markdown_file].reenable
    Rake::Task[:compile_markdown_file].invoke(locale, cefr_level, chapter_name)
  end
end

desc "Compile one TOC per locale from the available HTML files, also incorporating chapter TOCs"
task :build_tocs do
  locale = '' # Will be redefined later, needs to be available within this scope, though
  Dir.glob(Config.cache_path+'chapters'+'??') do |locale_dir|
    # Build a hash of hashes containing the TOC structure
    toc = {}
    %x{find #{locale_dir} -type f -name '*.html' | sort}.split("\n").each do |chapter_file|
      /.*\/(?<locale>[a-z][a-z])\/(?<cefr_level>.*)-(?<chapter_name>.*)\.html/ =~ chapter_file
      toc[cefr_level] = {} unless toc[cefr_level]
      toc[cefr_level][chapter_name] = {contents: nil} unless toc[cefr_level][chapter_name]
      # Need to read the chapter-internal TOC now, if one exists
      chapter_toc_file = chapter_file.gsub(/\/chapters\//, '/tocs/')
      if File.exist?(chapter_toc_file)
        chapter_toc = File.read(chapter_toc_file)
        @html = Nokogiri::HTML::DocumentFragment.parse(chapter_toc)
        @html.css('a').each do |link|
          link.attributes['href'].value = "/#{locale}/#{cefr_level}/#{chapter_name}#{link.attributes['href']}"
        end
        toc[cefr_level][chapter_name][:contents] = @html.to_html(encoding: 'UTF-8')
      end
    end
    # Read the hash of hashes, building a nested <ul>
    # structure from it to be displayed in the webapp
    @html = Nokogiri::HTML::DocumentFragment.parse('')
    Nokogiri::HTML::Builder.with(@html) do |d|
      d.ul {
        toc.each do |cefr_level,v1|
          d.li(class: 'level_1') {
            d.a(href: "/#{locale}/#{cefr_level}") {d.text cefr_level}
            d.ul {
              v1.each do |chapter_name,v2|
                d.li(class: 'level_2') {
                  d.a(href: "/#{locale}/#{cefr_level}/#{chapter_name}") {d.text chapter_name}
                  d.cdata v2[:contents] if v2[:contents]
                }
              end
            }
          }
        end
      }
    end
    # Write the nested <ul> structure to a cache file
    toc_file = Config.cache_path+'tocs'+"#{locale}.html"
    File.open(toc_file, 'w') do |f|
      puts "Writing #{toc_file}"
      f.write @html.to_html(encoding: 'UTF-8')
    end
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
      target = Config.cache_path+'chapters'+locale+target_file_name
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

desc "Copy all assets (images, fonts, etc.) to their appropriate locations to be served by the webapp"
task :copy_assets do
  # TODO: remove next four lines ones legacy conversion complete.
  legacy_media_path = Config.public_path+'media'
  puts "Deleting and re-linking #{legacy_media_path}"
  FileUtils.rm_f legacy_media_path # Only required because 'ln -sf' is f***** up...
  FileUtils.ln_s Config.data_path, legacy_media_path
  # TODO: Replace by calling a proper asset pipeline at some point.
  global_assets  = Dir.glob(Config.template_path+'{images,fonts}')
  puts "Copying #{global_assets.join(', ')}"
  FileUtils.cp_r global_assets, Config.public_path
  chapter_assets = Dir.glob(Config.data_path+'chapters'+'*'+'images'+'*')
  Dir.glob('/home/jrs/Projects/textbookr/data/aop/chapters/*/images/*').each do |p|
    puts "Copying #{p}"
    FileUtils.cp p, Config.public_path+'images' if FileTest.file?(p)
  end
end

desc "Convert all existing Word XML files to Markdown"
task :convert_docx_files do
  %x[find data/aop/chapters/word -type f -name '*.docx'].split("\n").each do |source|
    target_file_name = source.gsub(/\/word\//, '/test/texts/').gsub(/\.docx/, '.md')
    FileUtils.mkdir_p File.dirname(target_file_name)
    sh "pandoc -f docx -t markdown_github -o '#{target_file_name}' '#{source}'"
  end
end
=end
