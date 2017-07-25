require 'sanitize'

module SinatraApp
  class TOC
    def initialize(locale, book = nil)
      @locale = locale
      @book_or_books = (book && !book.new_record? ? [book] : ContentFragment.empty_chapters).uniq
    end
    
    def html(url_path = nil)
      build_toc(@book_or_books, url_path)
    end
    
    private
    
    def link_class(p1, p2, next_marker = false)
      p1 = p1[3..p1.length]
      p2 = URI.encode p2
      classes = []
      classes << :active if p1 == p2
      classes << :next if !classes.any? && next_marker
      classes.any? ? " class='#{classes.join(' ')}'" : ''
    end
  
    def build_toc(book_level_fragments, url_path = nil)
      toc = ''; next_marker = false
      book_level_fragments.each do |f|
        link_path = URI.encode(f.url_path)
        link_class = link_class(link_path, url_path, next_marker)
        next_marker = true if link_class != '' # The current element is active, so we need to mark the next element soon!
        toc << "<ul class='level_1'>\n"
        toc << "  <li class='level_1'><span#{link_class}>#{f.heading_without_html}</span></li>\n"
        # Get them *all* to save on SQL queries - the only other query will be the one for the specific fragment selected from the TOC
        # Also, we're only selecting the info we need to save on execution and network time
        chapter_level_fragments = ContentFragment.
          select('id, locale, book, chapter, heading').
            where("locale = ? AND book = ? AND length(chapter) > 0", f.locale, f.book)
        # Convert ActiveRecord results into Array of Hashes
        # https://stackoverflow.com/questions/15427936/how-to-convert-activerecord-results-into-a-array-of-hashes
        toc << drill_deeper(chapter_level_fragments.map(&:attributes), nil, url_path, next_marker)
        toc << "</ul>"
      end
      toc
    end

    def drill_deeper(fragments, parent = nil, url_path = nil, next_marker = false)
      depth = parent ? parent['chapter'].count('.') + 2 : 2
      toc = ''
      children_fragments = reduce_fragments(fragments, depth, parent)
      if children_fragments.any?
        display_depth = parent ? parent['chapter'].split('.').length + 2 : depth # TODO: test thoroughly!
        ul_spaces = ''; (display_depth-1).times {ul_spaces << '  '}
        toc << "#{ul_spaces}<ul class='level_#{display_depth}'>\n"
        children_fragments.each do |f|
          display_depth = f['chapter'].split('.').length + 1 # TODO: this too!
          li_spaces = ''; (display_depth).times {li_spaces << '  '}
          f['path'] = URI.encode("/#{[f['locale'], f['book'], f['chapter']].join('/')}")
          f['name'] = Sanitize.clean([f['chapter'], f['heading']].join(' ')).gsub(/\n+/, ' ').strip # Completely remove all markup.
          f['class'] = link_class(f['path'], url_path, next_marker)
          next_marker = true if f['class'] != ''
          toc << "#{li_spaces}<li class='level_#{display_depth}'><a#{f['class']} href='#{f['path']}'>#{f['name']}</a>\n"
          toc << drill_deeper(fragments, f, url_path, next_marker)
        end
        toc << "#{ul_spaces}</ul>\n#{ul_spaces}</li>\n"
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
