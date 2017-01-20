require_relative 'kramdown/kramdown_parser'
require_relative 'core/string'
require 'nokogiri'

module Textbookr
  class Parser
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
                  args[:cefr_level]    +
                  "#{args[:chapter_name]}.html" }
      @outfile = {
        filename: Config.cache_path        +
                  'chapters'+args[:locale] +
                  html_file_name }
    end

    def self.parse(args = {})
      ch = self.new(args)
      ch.parse
    end
    
    def parse
      read_infile
      extract_toc
      write_outfiles
    end
    
    private

    def read_infile
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
      items = []
      # kramdown/master/lib/kramdown/converter/pdf.rb:550
      header_info = lambda do |el,type|
        if el.type == type
          case type
            when :header then el.attr['id']
            when :text then el.value
          end
        else
          el.children.map {|c| header_info.call(c, type)}.join('')
        end
      end
      # kramdown/master/lib/kramdown/converter/pdf.rb:550, modified
      # TODO: rewrite to produce nested unordered HTML list
      add_section = lambda do |item, parent|
        data = {
          text: header_info.call(item.value, :text),
          id: header_info.call(item.value, :header)
        }
# TODO: Fix below!
=begin
        if parent
          toc << [data]
        else
          toc << data
        end
=end
        items << data
        item.children.each {|c| add_section.call(c, parent)}
      end
      @tocfile[:kramdown].children.each do |item|
        add_section.call(item, nil)
      end
      @tocfile[:html] = Nokogiri::HTML::DocumentFragment.parse('')
      Nokogiri::HTML::Builder.with(@tocfile[:html]) do |d|
        d.ul {
          items.each {|item|
            d.li {
              d.a(href: "##{item[:id]}") {d.text item[:text]}
            }
          }
        }
      end
      # Careful, as Nokogiri does not by default use UTF-8!
      @tocfile[:contents] = @tocfile[:html].to_html(encoding: 'UTF-8')
    end
    
    def write_outfiles
      [@tocfile, @outfile].each do |f|
        FileUtils.mkdir_p(f[:filename].dirname)
        File.open(f[:filename], 'w') do |d|
          puts "Writing #{f[:filename]}"
          d.puts f[:contents]
        end
      end
    end
  end
end
