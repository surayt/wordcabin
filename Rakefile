require 'fileutils'
require 'pathname' # TODO: use it!

ROOT = Pathname(__FILE__).dirname
require_relative (ROOT + 'config.rb').expand_path

task default: [:clean, :build, :copy_legacy_files, :serve]

task :clean do
  sh "find #{Pathname(CONFIG[:cache_path]).expand_path} -type f -name '*.html' -exec rm {} \\;"
end

task :build do
  INFILES=File.join(Pathname(CONFIG[:data_path]).expand_path, "**", "*.md")
  Dir.glob(INFILES).each do |infile|
    metadata = Pathname(infile).each_filename.to_a.last(2).join('/')
    /(?<locale>.*)\/(?<cefr_level>.*)-(?<chapter_name>.*)\.md/ =~ metadata
    sh "ruby script/compile #{locale} #{cefr_level} #{chapter_name}"
  end
end

# Yes, this task duplicates a lot of what's in the build task,
# but that's fine as it is only meant to be here until the
# transition to Markdown input files is complete.
task :copy_legacy_files do
  INFILES=%x[find data/aop/chapters/*/texts -type f -name '*-*' ! -name '*.md'].split("\n")
  INFILES.each do |source|
    unless File.exist?("#{source}.md")
      metadata = Pathname(source).each_filename.to_a.last(2).join('/')
      /(?<locale>.*)\/(?<cefr_level>.*)-(?<chapter_name>.*)/ =~ metadata
      target = Pathname(CONFIG[:cache_path])+'chapters'+locale+"#{cefr_level}-#{chapter_name}.html"
      unless File.exist?(target)
        puts "Copying #{source}"
        FileUtils.mkdir_p(target.dirname)
        FileUtils.cp(source, target)
      end
    end
  end
end

task :serve do
  sh "ruby script/server"
end
