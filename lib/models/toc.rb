require 'sanitize'

module SinatraApp
  class TOC
    def initialize(locale, book = nil)
      @locale = locale
      @book = book
    end
    
    def html
      fragments = if @book
        ContentFragment.where(locale: @locale, book: @book, chapter: '')
      else
        ContentFragment.where(locale: @locale, chapter: '')
      end
      build_toc(fragments.order(:book).uniq)
    end
    
    private
  
    def build_toc(book_level_fragments)
      depth = 1
      toc = ''
      book_level_fragments.each do |f|
        toc << "<ul>\n"
        toc << "<li class='level_#{depth}'><a href='#{f.path}'>#{f.heading_without_html}</a></li>\n"
        # Get them *all* to save on SQL queries - the only other query will be the one for the specific fragment selected from the TOC
        # Also, we're only selecting the info we need to save on execution and network time
        chapter_level_fragments = ContentFragment.select('id, locale, book, chapter, heading').where("locale = ? AND book = ? AND length(chapter) > 0", f.locale, f.book).order(:chapter)
        # Convert ActiveRecord results into Array of Hashes
        # https://stackoverflow.com/questions/15427936/how-to-convert-activerecord-results-into-a-array-of-hashes
        toc << drill_deeper(chapter_level_fragments.map(&:attributes))
        toc << "</ul>\n"
      end
      toc
    end

    def drill_deeper(fragments, parent = nil)
      depth = parent ? parent['chapter'].count('.')+2 : 2
      toc = ''
      children_fragments = reduce_fragments(fragments, depth, parent)
      if children_fragments.any?
        toc << "<ul>\n"
        children_fragments.each do |f|
          f['path'] = "/#{[f['locale'], f['book'], f['chapter']].join('/')}"
          f['name'] = Sanitize.clean([f['chapter'], f['heading']].join(' '))
          toc << "<li class='level_#{depth}'><a href='#{f['path']}'>#{f['name']}</a>\n"
          toc << drill_deeper(fragments, f)
        end
        toc << "</ul></li>\n"
      end
      toc
    end

    def reduce_fragments(fragments, depth, parent)
      if parent
        p_ch_len = parent['chapter'].length
        fragments = fragments.select {|f| f['chapter'][0...p_ch_len] == parent['chapter'] && f['chapter'].length > p_ch_len}
      else
        depth = depth - 1
      end
      fragments.select {|f| f['chapter'][/^\d+(?:\.\d+){#{depth-1}}$/]} # TODO: Entweder -1 oder -2, aber beides stimmt nicht???
    end
  end
end
