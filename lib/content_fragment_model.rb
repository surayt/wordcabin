module SinatraApp
  class ContentFragment < ActiveRecord::Base
    def path
      ('/'+[locale, book, chapter].join('/')).chomp('/')
    end
  end
end
