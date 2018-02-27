require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application
  
    # Set locale info on each request
    
    before do
      locale_from_url_path = request.path_info.split('/')
      locale_from_url_path = locale_from_url_path[1] ? locale_from_url_path[1].to_sym : nil
      begin
        if I18n.available_locales.include? locale_from_url_path
          session[:ui_locale] = I18n.locale = \
            current_user.preferred_locale || locale_from_url_path
          session[:content_locale] = locale_from_url_path || current_user.preferred_locale || I18n.default_locale
        else
          session[:ui_locale] = session[:content_locale] = I18n.locale = \
            current_user.preferred_locale || extract_locale_from_accept_language_header
        end
      rescue I18n::InvalidLocale
        puts "attempted access to non-existing content locale #{params[:locale].inspect}".red # TODO: logger.debug
        redirect to('/')
      end
    end
    
    # Prepend all routes with locale info, but skip locale-independent ones
    # Static routes (i.e., any file inside of public/) never arrive here anyways
    
    before '/:locale/?*' do
      pass if %w{assets files favicon.ico __sinatra__}.include? params[:locale]
      request.path_info = "/#{params[:splat].first}"
    end
  end
end
