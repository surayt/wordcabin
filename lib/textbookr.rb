require_relative 'kramdown_parser'
require_relative 'string'
require 'nokogiri'

module Textbookr
  class Chapter
    def initialize(args)
      dir_name = "#{args[:cefr_level]}-#{args[:chapter_name]}"
      md_file_name = "#{dir_name}.md"
      html_file_name = "#{dir_name}.html"
      @infile = {
        filename: Config.data_path                         + 
                  'chapters'+dir_name+'texts'+args[:locale] +
                  md_file_name }
      @tocfile = {
        filename: Config.cache_path    +
                  'tocs'+args[:locale] +
                  html_file_name }
      @outfile = {
        filename: Config.cache_path        +
                  'chapters'+args[:locale] +
                  html_file_name }
    end

    def write_files
      [@tocfile, @outfile].each do |f|
        FileUtils.mkdir_p(f[:filename].dirname)
        File.open(f[:filename], 'w') do |d|
          puts "Writing #{f[:filename]}"
          d.puts f[:contents]
        end
      end
    end

    def self.convert(args = {})
      ch = self.new(args)
      ch.parse_infile
      ch.extract_toc
      ch.write_files
    end

    def parse_infile
      @infile[:contents] = IO.read(@infile[:filename])
      # Using GitHub-flavored Markdown because that's arguably
      # what most non-technical authors may already have been
      # exposed to by their more technical peers.
      @infile[:kramdown] = Kramdown::Document.new(@infile[:contents], parse_block_html: true, input: 'GFM')
      @infile[:xml] = Nokogiri::HTML::DocumentFragment.parse(@infile[:kramdown].to_html)
      # Tag Syriac-containing elements as such
      @infile[:xml].traverse do |node|
        if text = node.xpath('text()').to_html(encoding: 'UTF-8')
          if !text.blank? && text.chars.first.match(/\p{Syriac}/)
            node['lang'] = 'syr'
          end
        end
      end
      # Careful, as Nokogiri does not by default use UTF-8!
      @outfile[:contents] = @infile[:xml].to_html(encoding: 'UTF-8')
    end

    def extract_toc
      @tocfile[:kramdown] = Kramdown::Converter::Toc.convert(@infile[:kramdown].root).first
      @tocfile[:contents] = ''
      items = []
      # kramdown/master/lib/kramdown/converter/pdf.rb:550
      text_of_header = lambda do |el|
        if el.type == :text
          el.value
        else
          el.children.map {|c| text_of_header.call(c)}.join('')
        end
      end
      # kramdown/master/lib/kramdown/converter/pdf.rb:550, modified
      # TODO: rewrite to produce nested unordered HTML list
      add_section = lambda do |item,depth|
        text = text_of_header.call(item.value)
        items << [text, depth]
        item.children.each {|c| add_section.call(c, depth+1)}
      end
      @tocfile[:kramdown].children.each do |item|
        add_section.call(item, 0)
      end
      @tocfile[:contents] += items.inspect # TODO: Make proper HTML!
    end
  end
end
