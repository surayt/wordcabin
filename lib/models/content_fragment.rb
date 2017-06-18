module SinatraApp
  class ContentFragment < ActiveRecord::Base
    def path
      ('/'+[locale, book, chapter].join('/')).chomp('/')
    end
    
    def heading_and_text
      '<header>'+heading+'</header><section>'+html+'</section'
    end
  end
end
