#!/usr/bin/env ruby

require 'bundler/setup'
require 'kramdown'
require_relative '../asciitable/asciitable'

module Kramdown
  module Parser
    class Kramdown
      THIRDPARTY_PARSERS = %w{asciitable table t}

      def parse_codeblock_fenced
        if @src.check(self.class::FENCED_CODEBLOCK_MATCH)
          start_line_number = @src.current_line_number
          @src.pos += @src.matched_size
          lang = @src[3].to_s.strip
          if thirdparty = THIRDPARTY_PARSERS.include?(lang)
            cat = :raw
            case lang.to_sym
              when :asciitable, :table, :t then
                src = ASCIITable.parse(@src[5])
            end
          else
            cat = :codeblock
            src = @src[5]
          end
          # puts src.inspect
          el = new_block_el(cat, src, nil, location: start_line_number)
          unless thirdparty || lang.empty?
            el.options[:lang] = lang
            el.attr['class'] = "language-#{@src[4]}"
          end
          @tree.children << el
          true
        else
          false
        end
      end
    end
  end

  class Element
    def to_s
      @value
    end

    def value=(string)
      @value = string
    end
  end
end
