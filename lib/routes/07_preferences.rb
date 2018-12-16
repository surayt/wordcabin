require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application
  
    get '/preferences' do
      if @user = current_user
        @locales = I18n.available_locales
        haml :'preferences'
      else
        flash[:error] = 'You have to be logged in to perform this operation' # TODO: I18n!
        redirect to('/')
      end
    end
    
    post '/preferences' do
      if @user = current_user
        unless @user.update_attributes(params[:user])
          flash[:error] = @user.errors.full_messages.join(', ')
        end
      else
        flash[:error] = 'You have to be logged in to perform this operation' # TODO: I18n!
      end
      redirect back.with_locale(current_user.preferred_locale)
    end
  end
end
