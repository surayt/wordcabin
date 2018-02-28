require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application

    # Handle logging in and logging out.
    
    get '/login' do
      @user = User.new
      haml :'login'
    end
    
    post '/login' do
      # TODO: What about strong params?
      if @user = User.find_by_email(params[:user_email])
        if @user.authenticate(params[:user_password])
          session[:user_id] = @user.id
          flash[:notice] = I18n.t('routes.welcome', user: current_user.email.split('@').first)
          
          redirect to(URI.escape(params[:referer]) || '/') # The referer may and *will* contain special characters!
        end
      end
      flash[:error] = I18n.t('routes.login_error')
      redirect back
    end
    
    get '/logout' do
      current_user && session[:user_id] = nil
      flash[:notice] = I18n.t('routes.session_closed')
      redirect '/'
    end
  end
end
