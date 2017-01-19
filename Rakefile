require 'fileutils'
require_relative 'config.rb'
require_relative Config.lib_path+'textbookr.rb'

task default: [:clean, :build_all, :copy_legacy_files]

task :clean do
  sh "find #{Config.cache_path} -type f -name '*.html' -exec rm {} \\;"
end

task :build, [:locale, :cefr_level, :chapter_name] do |t, args|
  unless args.to_a.size == 3
    fail "You must supply locale, cefr_level and chapter_name"
  end
  Textbookr::Chapter.convert(args)
end

task :build_all do
  %x{find #{Config.data_path} -type f -name '*.md'}.split("\n").each do |source|
    metadata = Pathname(source).each_filename.to_a.last(2).join('/')
    args = /(?<locale>.*)\/(?<cefr_level>.*)-(?<chapter_name>.*)\.md/ =~ metadata
    Rake::Task[:build].reenable
    Rake::Task[:build].invoke(locale, cefr_level, chapter_name)
  end
end

# Yes, this task duplicates a lot of what's in the build task,
# but that's fine as it is only meant to be here until the
# transition to Markdown input files is complete.
task :copy_legacy_files do
  infiles = %x[find data/aop/chapters/*/texts -type f -name '*-*' ! -name '*.md'].split("\n")
  infiles.each do |source|
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
