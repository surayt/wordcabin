require 'fileutils'
require 'pathname' # TODO: use it!

ROOT = Pathname(__FILE__).dirname
require_relative (ROOT + 'config.rb').expand_path

task default: [:clean, :build, :serve]

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

task :serve do
  sh "ruby script/server"
end
