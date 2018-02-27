require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application    
  
    # Landing page showing the list of available L1s.
    
    get '/' do
      @fragment_sets = ContentFragment.empty_chapters
      @fragment_sets = @fragment_sets.published unless current_user.is_admin?
      @fragment_sets = @fragment_sets.group_by(&:book)
      if !@fragment_sets.any? && current_user.is_admin?
        redirect to("/#{locale}/new?view_mode=edit")
      else
        haml :index
      end
    end
  end
end
