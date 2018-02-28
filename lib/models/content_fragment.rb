require 'sanitize'

module Wordcabin 
  # A chapter belongs to the top-level element by having the same 'book' field value. There are no formal relationships!
  class ContentFragment < ActiveRecord::Base
    has_many :exercises

    default_scope { order("locale ASC, book ASC, chapter_padded ASC") }
    before_save :fill_sorting_column

    # CHECK: tests written!
    validates :book, presence: {message: I18n.t('models.chapter_format.book_must_be_present')}
    validates :locale, presence: {message: I18n.t('models.chapter_format.locale_must_be_present')}, length: {is: 2, message: I18n.t('models.chapter_format.locale_format')}
    validates :chapter, format: {with: /^[\d+.]*\d+$/, multiline: true, message: I18n.t('models.chapter_format.chapter_format')}, allow_blank: true

    # CHECK: tests written!
    validate :ensure_chapter_is_unique
    def ensure_chapter_is_unique
      recordset = ContentFragment.chapters(locale, book)
      recordset = recordset.where('id != ?', id) if id
      unique = !(recordset.map {|existing_fragment| existing_fragment.chapter}.include? chapter)
      errors.add(:chapter, I18n.t('models.chapter_format.chapter_already_exists')) unless unique
    end
    
    # CHECK: tests written!
    validate :ensure_chapter_is_book_or_has_parent
    def ensure_chapter_is_book_or_has_parent
      if chapter.blank?
        # It's a book!
        unique = !(ContentFragment.books(locale).map {|existing_fragment| existing_fragment.book}.include? book)
        errors.add(:book, I18n.t('models.chapter_format.book_already_exists')) unless unique
      else
        # It's not a book!
        has_parent = ContentFragment.book(locale, book)
        errors.add(:book, I18n.t('models.chapter_format.book_is_not_a_book')) unless has_parent
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
      if chapter_padded.blank?
        # It's a book!
        has_no_children = !ContentFragment.chapters(locale, book).any?
      else
        # It's not a book!
        has_no_children = true
        ContentFragment.where("chapter_padded LIKE ?", "#{chapter_padded}%").chapters(locale, book).each do |possible_child|
          if chapter_padded.split('.').count < possible_child.chapter_padded.split('.').count
            has_no_children = false 
            break
          end
        end
      end
      # Not an ordinary validation callback, thus need to throw(:abort).
      # https://stackoverflow.com/questions/123078/how-do-i-validate-on-destroy-in-rails
      unless has_no_children
        errors.add(:base, I18n.t('models.chapter_format.cant_destroy'))
        throw(:abort)
      end
    end
    
    def heading_without_html
      h = Sanitize.clean(heading)
      h.strip.gsub(/ /, '').blank? ? book : h # TODO: Why is .blank? not enough?
    end

    def next_unused
      next_chapter = '0'
      if chapter.blank?
        fragment = ContentFragment.last
        if !fragment || fragment.chapter.blank?
          fragment = ContentFragment.new(locale: locale, book: book, chapter: next_chapter)
        end
      else
        fragment = self
      end
      chapter_levels = fragment.chapter.split '.'
      last_segment = chapter_levels.last.to_i
      loop do
        last_segment += 1
        chapter_levels[-1] = last_segment.to_s
        next_chapter = chapter_levels.join '.'
        break if !ContentFragment.chapter(locale, book, next_chapter)
      end
      ContentFragment.new(locale: locale, book: book, chapter: next_chapter)
    end

    # Meant for private use, but we'll see...
    #
    scope :non_empty_chapters, -> { where("chapter <> ''") }
    scope :empty_chapters, -> { where(chapter: [nil, '']) }
    #
    # Meant for public use...
    # (The singular methods are not scopes because AR is still sh** sometimes,
    #  also cf. https://stackoverflow.com/a/21653695 for the solution used.)
    #
    def self.book(locale, book); where(locale: locale, book: book.force_utf8).empty_chapters.first; end
    def self.chapter(locale, book, chapter); where(locale: locale, book: book.force_utf8, chapter: chapter.force_utf8).first; end
    scope :published, -> { where(is_published: true) }
    #
    # (For the plural methods, care must be taken to chain them with #where at
    #  the end of the chain, so that they always return a set, never an item.)
    #
    scope :books, ->(locale) { empty_chapters.where(locale: locale) }
    scope :chapters, ->(locale, book) { non_empty_chapters.where(locale: locale, book: book) }
    
    def fill_sorting_column
      unless chapter.blank?
        lmnts = chapter.split '.'
        self.chapter_padded = lmnts.map {|l| l.rjust(10, '0')}.join '.'
      end
    end
    
    def parent
      ContentFragment.book(locale, book)
    end
    
    def first_child
      ContentFragment.chapters(locale, book).first
    end
  
    def url_path(method = :get)
      if ContentFragment.count > 1 && chapter.blank? && !new_record?
        # We're dealing with a book.
        first_child_url_path
      else
        # We're dealing with content.
        path = case method
          when :get    then new_record? ? 'content_fragments/new' : [book, chapter].join('/').chomp('/')
          when :post   then new_record? ? 'content_fragments/new' : "content_fragments/#{id}"
          when :delete then "content_fragments/#{id}"
        end
        "/#{locale}/#{path}"
      end
    end
  
    def book_url_path
      "/#{[locale, book].join '/'}".chomp '/'
    end
    
    def first_child_url_path
      "/#{[locale, book, first_child ? first_child.chapter : chapter].join '/'}".chomp '/'
    end
  end
end
