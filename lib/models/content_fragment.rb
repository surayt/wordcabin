require 'sanitize'

module SinatraApp
  # A chapter belongs to the top-level element by having the same 'book' field value. There are no formal relationships!
  class ContentFragment < ActiveRecord::Base
    default_scope { order("locale ASC, book ASC, chapter_padded ASC") }
    before_save :fill_sorting_column

    # TODO: i18n!
    validates :book, presence: {message: 'must be present, even when chapter is empty.'}
    validates :locale, presence: {message: 'must and should be present'}, length: {is: 2, message: 'must be in ISO 3166-1 Alpha 2 encoding.'}
    validates :chapter, uniqueness: {scope: [:locale, :book], message: 'must be unique within book and locale.'}
    validates :chapter, format: {with: /^[\d+.]*\d+$/, multiline: true, message: 'must be in a format like 2.10.4.5, etc.'}, allow_blank: true # TODO: allow_nil, even?
    # TODO: check whether:
    # - new element would, given its chapter string, have a parent?
    # validate :ensure_chapter_has_parent # TODO: Disabling, because it still has problems.
    # - element to be deleted has children that need to be deleted?
    before_destroy :chapter_has_no_children
    
#    def ensure_chapter_has_parent
#      if chapter.blank? && !ContentFragment.book(locale, book).any?
#        errors.add(:chapter, 'can only be specified together with an already existing book! To create a new book, leave empty.')
#      end
#    end
    
    def ensure_chapter_has_no_children
      if chapter.blank? && ContentFragment.where(locale: locale, book: book).non_empty_chapters.any?
        errors.add(:base, "Can't delete book that still has any children!")
        return false
      end
      return true
    end
  
    def path
      ('/'+[locale, book, chapter].join('/')).chomp('/')
    end
    
    def heading_without_html
      h = Sanitize.clean(heading)
      h == '' ? book : h
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
    
    scope :non_empty_chapters, -> { where("chapter <> ''") }
    scope :empty_chapter, -> { where(chapter: [nil, '']) }
    scope :book, ->(locale, book) { where(locale: locale, book: book).empty_chapter }
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
