module Wordcabin 
  class Server < Sinatra::Application
    ###########################################################################
    # Helper Methods                                                          #
    ###########################################################################

    helpers do
      # Just some convenience (nicer to type current_user in views, etc.)
      def current_user
        (User.find(session[:user_id]) if session[:user_id]) || User.new
      end
      
      def view_mode
        unless request.path_info =~ /exercises/
          if params[:view_mode]
            params[:view_mode].to_sym
          else
            :preview
          end
        end
      end

      def locale
        session[:content_locale] # Different from session[:ui_locale] which == I18n.locale! (see routes.rb)
        # Required for swapping the UI around
        session[:ui_origin] = :left
        session[:ui_origin] = :right if session[:content_locale]
        return session[:content_locale]
      end
      
      # It is what it is...
      def content_class
        c = []
        path_info = request.path_info.split('/')
        if current_user.is_admin?
          c << :admin
        end
        if path_info[1] != 'exercises'
          if current_user.is_admin? && view_mode != :preview
            c << :editor
          else
            c << :user
          end
        end
        if path_info.length < 2
          c << :index 
        else
          c << if %w{login exercises keyboard preferences}.include? path_info[1]
            path_info[1].to_sym
          else
            :contents
          end
        end
        c.join(' ') # Something like e.g. "admin editor exercises" (which would
                    # be a user who's an admin and who's working on editing exercises.
                    # The string is used by the CSS files to style things appropriately.
      end
    
      def icon(name)
        "<i class=\"fa fa-#{name}\"></i>"
      end
    end
  end
end
