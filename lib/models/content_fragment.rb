require 'sanitize'

module SinatraApp
  class ContentFragment < ActiveRecord::Base
    # TODO: i18n!
    validates :book, presence: {message: 'must be present, even when chapter is empty'}
    validates :locale, presence: {message: 'must and should be present'}, length: {is: 2, message: 'must be in ISO 3166-1 Alpha 2 encoding'}
    validates :chapter, uniqueness: {scope: [:locale, :book], message: 'must be unique within book and locale'}
    validates :chapter, format: {with: /^[\d+.]*\d+$/, multiline: true, message: 'must be in a format like 2.3.4.5, etc.'}, allow_blank: true
  
    def path
      ('/'+[locale, book, chapter].join('/')).chomp('/')
    end
    
    def heading_without_html
      h = Sanitize.clean(heading)
      h == '' ? book : h
    end
    
    def heading_and_text
      "<header>#{heading}</header><section>#{html}</section>"
    end
  end
end
