require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application    
  
    # Landing page showing the list of available L1s.
    
    get '/' do
      @book_sets = ContentFragment.empty_chapters
      @book_sets = @book_sets.published unless current_user.is_admin?
      @book_sets = @book_sets.group_by(&:book)
      if !@book_sets.any? && current_user.is_admin?
        redirect to("/#{locale}/content_fragments/new?view_mode=edit")
      else
        haml :'index'
      end
    end
  end
end
