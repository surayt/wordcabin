require 'fileutils'
require 'nokogiri'
require_relative 'config.rb'
require_relative Config.lib_path+'parser.rb'

task default: [:clean, :build_all, :copy_legacy_files, :copy_assets, :build_tocs]

# TODO: The whole asset handling (:clean and :copy_assets)
# should really be done by a proper asset pipeline. Holding
# off on it until the legacy conversion is finished.

desc "Remove all automatically compiled or copied files from the cache and public dirs"
task :clean do
  sh "rm -rf #{Config.cache_path}/chapters #{Config.cache_path}/sass #{Config.cache_path}/tocs #{Config.public_path}/images #{Config.public_path}/fonts #{Config.public_path}/stylesheets"
  sh "rm -f #{Config.public_path}/media" # TODO: Remove when legacy conversion complete!
end

desc "Compile the Markdown file(s) specified by the arguments into HTML"
task :build_one, [:locale, :cefr_level, :chapter_name] do |t, args|
  unless args.to_a.size == 3
    fail "You must supply locale, cefr_level and chapter_name"
  end
  Textbookr::Parser.parse(args)
end

desc "Compile all Markdown files into HTML"
task :build_all do
  %x{find #{Config.data_path} -type f -name '*.md'}.split("\n").each do |source|
    # By way of '=~' and named matching groups, Ruby directly creates a local variable for each group
    /.*\/(?<cefr_level>.*)-(?<chapter_name>.*)\/texts\/(?<locale>[a-z][a-z])\/.*/ =~ source
    Rake::Task[:build_one].reenable
    Rake::Task[:build_one].invoke(locale, cefr_level, chapter_name)
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
          d.li {
            d.a(href: "/#{locale}/#{cefr_level}") {d.text cefr_level}
            d.ul {
              v1.each do |chapter_name,v2|
                d.li {
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
    File.open(Config.cache_path+'tocs'+"#{locale}.html", 'w') do |f|
      puts "Writing to #{locale}.html"
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
        FileUtils.cp(source, target)
      end
    end
  end
end

desc "Copy all assets (images, fonts, etc.) to their appropriate locations to be served by the webapp"
task :copy_assets do
  sh "cp -a #{Config.template_path}/images #{Config.template_path}/fonts #{Config.public_path}"
  sh "ln -sf #{Config.data_path} #{Config.public_path}/media" # TODO: Remove when legacy conversion complete!
  sh "find #{Config.data_path}/chapters/*/images -type f -exec cp {} #{Config.public_path}/images \\;"
end

desc "Start the webapp server on port 4567"
task :serve do
  sh "ruby config.ru" # FIXME: why does rerun not work anymore?
end
