# Remember: each line of code one liability!
#
# Parse ASCII tables as produced by www.tablesgenerator.com/text_tables.
# Copyright (C) 2016 J. R. Schmid <jrs+git@weitnahbei.de>
#
# List of todos:
# - Implement support for multi-line cell contents
# - Implement more output options than just HTML
# - Ponder having self.parse return an ASCIITable object on which
#   #to_html can be called, or of course #to_something_else as soon
#   as that's implemented. @t2 might make for a good starting point
#   for ASCIITable#to_hash and ASCIITable.to_ary.

require 'nokogiri'
require 'kramdown'
require 'sanitize'

class ASCIITable
  def initialize(string = '', opts = {})
    @string = string
    @t1 = []
    @t2 = []
    @colwidths = []
    @opts = opts
    @opts[:header_row] ||= false
    @opts[:markdown]   ||= true
  end

  def self.parse(string, opts = {})
    instance = self.new(string, opts)
    begin
      instance.pass1
      instance.pass2
      html = instance.to_html
    rescue Exception => e
	  trace = "ASCIITable: Error: Malformed table. Parser trace follows:\n\t" +
		e.backtrace.map {|l| l.split('/').last}[0...3].join("\n\t")
      STDERR.puts trace
	  html = "<pre class=\"error\">#{trace.gsub(/[<>]/, '')}</pre>"
    end
	html
  end

  def pass1
    @string.each_line.with_index do |row,y|
      if (y % 2 == 0)
        # border
        @colwidths += (0 ... row.size).find_all {|i| row[i] == '+'}
        row = row.gsub(/\n/, '').split('+'); row.shift
        @t1 << row
      else
        # content
        row = row.gsub /(^\|)|(\|$)\n?/, ''
        cols = row.split('|')
        @t1 << []
        cols.each_with_index {|col,x|
          @t1.last << {
            text: col.gsub(/(^ +| +$)/, ''),
            size: col.size+1
          }
        }
      end
    end
    @colwidths.uniq!.sort!
  end

  def pass2
    @t1.each_with_index do |row,y|
      if (y % 2 == 1) # only uneven rows are cells, the rest are borders!
        @t2 << []
        @xpos = 0
        row.each_with_index do |col,x|
          if (colspan = compute_colspan(col)) > 1
            col[:colspan] = colspan
          end
          if (rowspan = compute_rowspan(x, y, row, col)) > 1
            col[:rowspan] = rowspan if rowspan > 1
          end
          @t2.last << col
        end
      end
    end
  end

  def compute_colspan(col)
    ps1 = @colwidths.index(@xpos)
    @xpos += col[:size] unless @xpos >= @colwidths.last
    ps2 = @colwidths.index(@xpos)
    return (ps1 && ps2) ? ps2-ps1 : 1
  end

  def compute_rowspan(x, y, row, col)
    rowspan = 1
    # checking ahead in case of two-row-only table
    border = @t1[y+1] ? @t1[y+1][x] : false
    # only if it's at least 2 do we check whether it goes further to save on cycles
    if border && border.match(/ /)
      (y+1..@t1.size).step(2) do |ystep|
        border = @t1[ystep][x]
        if border && border.match(/ /)
          rowspan += 1
        # once we hit a border, we stop
        else
          break
        end
      end
    end
    rowspan
  end

  # TODO: Figure out how to do this in a way that preserves the Syriac letter forms!
  def parse_md(text)
    unless text.empty?
      text = Kramdown::Document.new(text).to_html
      text = Sanitize.fragment(text, Sanitize::Config::RESTRICTED)
      text = text.split.join(' ') # Get rid of linebreaks, multiple spaces
    end
    text
  end

  # TODO: Wrap appropriately in <thead> and <tbody>
  def to_html
    n = 0
    @doc = Nokogiri::XML::DocumentFragment.parse('')
    Nokogiri::XML::Builder.with(@doc) do |html|
      html.table('class' => 'asciitable') do
        @t2.each_with_index do |row,y|
          html.tr do
            row.each_with_index do |cell,x|
              opts = {}
              opts[:rowspan] = cell[:rowspan] if cell[:rowspan]
              opts[:colspan] = cell[:colspan] if cell[:colspan]
              text = parse_md(cell[:text]) if @opts[:markdown]
              if y == 0 && opts[:header_row]
                html.th(opts) {html << text}
              else
                if [x,y] == [0,0] && text.empty?
                  # cell at this location must exist in any case
                  html.td(opts) {html << ''}
                else
                  # any other location empty means row-/colspan
                  html.td(opts) {html << text} unless text.empty?
                end
              end
            end
          end
        end
      end
    end
    @doc.to_xhtml(encoding: 'UTF-8')
  end
end
