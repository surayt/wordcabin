require 'sanitize'

module SinatraApp
  # A chapter belongs to the top-level element by having the same 'book' field value. There are no formal relationships!
  class ContentFragment < ActiveRecord::Base
    default_scope { order("locale ASC, book ASC, chapter_padded ASC") }
    before_save :fill_sorting_column

    # TODO: i18n!
    # CHECK: tests written!
    validates :book, presence: {message: 'must be present, even when chapter is empty.'}
    validates :locale, presence: {message: 'must and should be present'}, length: {is: 2, message: 'must be in ISO 3166-1 Alpha 2 encoding.'}    
    validates :chapter, format: {with: /^[\d+.]*\d+$/, multiline: true, message: 'must be in a format like 2.10.4.5, etc.'}, allow_blank: true

    # TODO: i18n!
    # CHECK: tests written!
    # validate :ensure_chapter_is_unique # TODO: FIXME!
    def ensure_chapter_is_unique
      unique = !(ContentFragment.chapters(locale, book).map {|existing_fragment| existing_fragment.chapter}.include? chapter)
      errors.add(:chapter, 'already exists in this book for the selected language version.') unless unique
    end
    
    # TODO: i18n!
    # CHECK: tests written!
    validate :ensure_chapter_is_book_or_has_parent
    def ensure_chapter_is_book_or_has_parent
      if chapter.blank?
        # It's a book!
        unique = !(ContentFragment.books(locale).map {|existing_fragment| existing_fragment.book}.include? book)
        errors.add(:book, 'already exists for the selected language version.') unless unique
      else
        # It's not a book!
        has_parent = ContentFragment.book(locale, book).any?
        errors.add(:book, 'must already exist or otherwise the new content fragment will not be visible.') unless has_parent
      end
    end
    
    before_destroy :ensure_chapter_has_no_children
    def ensure_chapter_has_no_children
      # This one is non-trivial. It goes like this:
      # - are we a book?
      # - if so:
      #   - there can't be anything having our book name 
      #     AND locale
      # - if we're not a book:
      #   - nothing can have our book name
      #     AND locale
      #     AND a chapter with at least one more segment than we do where the segments leading up to the extra segment(s) is/are the same as our chapter's segments
      if chapter.blank?
        # It's a book!
        has_no_children = !ContentFragment.chapters(locale, book).any?
      else
        # It's not a book!
        has_no_children = true
        ContentFragment.where("chapter LIKE ?", "#{chapter}%").chapters(locale, book).each do |possible_child|
          if chapter.split('.').count < possible_child.chapter.split('.').count
            has_no_children = false 
            break
          end
        end
      end
      # Not an ordinary validation callback, thus need to throw(:abort).
      # https://stackoverflow.com/questions/123078/how-do-i-validate-on-destroy-in-rails
      unless has_no_children
        errors.add(:base, "Can't delete book that still has any children!")
        throw(:abort)
      end
    end
  
    def path
      ('/'+[locale, book, chapter].join('/')).chomp('/')
    end
    
    def heading_without_html
      h = Sanitize.clean(heading)
      h.blank? ? book : h
    end
    
    def heading_and_text
      h = ""
      h += "\n<header>#{heading}</header>" unless heading.blank?
      h += "\n<section>\n#{html}</section>\n"  unless html.blank?
      h
    end
    
    def first_child
      ContentFragment.where(locale: locale, book: book).non_empty_chapters.first
    end
    
    def parent
      ContentFragment.book(locale, book).first
    end

    # TODO: Rework. This is what it should work like:
    # - get our TOC level (i.e. x = 1, x.x = 2, x.x.x = 3)
    # - calculate the next chapter _in_that_level_
    # - if there's nothing there, go one higher
    # - if there's nothing there, go one higher
    # - ...
    # - if you reach the top (i.e., x) and there's still nothing there: return nil
    def next
      begin
        chapter_levels = chapter.split('.')
        chapter_levels[chapter_levels.size-1] = (chapter_levels.last.to_i + 1).to_s
        next_chapter = chapter_levels.join('.')
        fragments = ContentFragment.chapter(locale, book, next_chapter)
      rescue
        fragments = []
        last_fragment = ContentFragment.last
      end
      next_chapter ||= last_fragment.chapter.blank? ? 1 : (last_fragment.chapter.split('.').first.to_i + 1).to_s
      fragments.any? ? fragments.first : ContentFragment.new(locale: locale, book: book, chapter: next_chapter)
    end

    # Meant for private use, but we'll see...
    scope :non_empty_chapters, -> { where("chapter <> ''") }
    scope :empty_chapter, -> { where(chapter: [nil, '']) }
    # Meant for public use...
    scope :books, ->(locale) { where(locale: locale).empty_chapter }
    scope :book, ->(locale, book) { where(locale: locale, book: book).empty_chapter }
    scope :chapters, ->(locale, book) { where(locale: locale, book: book).non_empty_chapters.uniq }
    scope :chapter, ->(locale, book, chapter) { where(locale: locale, book: book, chapter: chapter) }
    
    def fill_sorting_column
      unless chapter.blank?
        lmnts = chapter.split '.'
        self.chapter_padded = lmnts.map {|l| l.rjust(10, '0')}.join '.'
      end
    end
    
    def url_path
      "/#{locale}/#{[URI.escape(book), first_child ? first_child.chapter : chapter].join('/')}"
    end
  end
end
