require 'fileutils'
require 'nokogiri'
require_relative 'config.rb'
require_relative Config.lib_path+'parser.rb'

task default: [:clean, :build_all, :copy_legacy_files]

task :clean do
  sh "find #{Config.cache_path} -type f -name '*.html' -exec rm {} \\;"
end

task :build, [:locale, :cefr_level, :chapter_name] do |t, args|
  unless args.to_a.size == 3
    fail "You must supply locale, cefr_level and chapter_name"
  end
  Textbookr::Parser.parse(args)
  # TODO: Encapsulate properly and put into a sensible place
  Dir.glob(Config.cache_path+'tocs'+'*').each do |locale_path|
    %x{find #{locale_path} -type f -name '*.html' ! -name 'all.html'}.split("\n").each do |fragment|
      metadata = Pathname(fragment).each_filename.to_a.last(3).join('/')
      /(?<locale>.*)\/(?<cefr_level>.*)\/(?<chapter_name>.*)\.html/ =~ metadata
      @html = Nokogiri::HTML::DocumentFragment.parse('')
      Nokogiri::HTML::Builder.with(@html) do |d|
        d.ul {
          d.li {
            d.text cefr_level
            d.ul {
              d.li {
                d.text chapter_name
                d.cdata File.read(fragment)
              }
            }
          }
        }
      end
      File.open(Config.cache_path+'tocs'+locale+'all.html', 'w') do |f|
        f.write @html.to_html(encoding: 'UTF-8')
      end
    end
  end
end

task :build_all do
  %x{find #{Config.data_path} -type f -name '*.md'}.split("\n").each do |source|
    metadata = Pathname(source).each_filename.to_a.last(2).join('/')
    /(?<locale>.*)\/(?<cefr_level>.*)-(?<chapter_name>.*)\.md/ =~ metadata
    Rake::Task[:build].reenable
    Rake::Task[:build].invoke(locale, cefr_level, chapter_name)
  end
end

# Yes, this task duplicates a lot of what's in the build task,
# but that's fine as it is only meant to be here until the
# transition to Markdown input files is complete.
task :copy_legacy_files do
  %x[find data/aop/chapters/*/texts -type f -name '*-*' ! -name '*.md'].split("\n").each do |source|
    unless File.exist?("#{source}.md")
      metadata = Pathname(source).each_filename.to_a.last(2).join('/')
      /(?<locale>.*)\/(?<cefr_level>.*)-(?<chapter_name>.*)/ =~ metadata
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

task :serve do
  sh "rerun config.ru"
end
