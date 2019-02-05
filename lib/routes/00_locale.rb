module Wordcabin 
  class Server < Sinatra::Application
  
    # Set locale info on each request
    
    before do
      # No need to deal with locales for an asset request...
      return if request.path_info.match /^\/(assets|files)/
      
      set_url_locale      
      set_ui_locale
      set_content_locale
      
      I18n.locale = session[:ui_locale]
    end
    
    # Prepend all routes with locale info, but skip locale-independent ones
    # Static routes (i.e., any file inside of static/) never arrive here anyways
    
    before '/:locale/?*' do
      pass if %w{assets files favicon.ico __sinatra__}.include? params[:locale]
      request.path_info = "/#{params[:splat].first}"
    end
    
    private
    
    def extract_locale_from_accept_language_header
      if accept_lang = request.env['HTTP_ACCEPT_LANGUAGE']
        l = accept_lang.scan(/^[a-z]{2}/).first
        d "00_locale: as per HTTP_ACCEPT_LANGUAGE, selecting [#{l}] as locale"
      else
        l = I18n.default_locale
        d "00_locale: selecting default locale [#{l}]"
      end
      return l
    end
    
    def set_url_locale
      locale_from_url_path = request.path_info.split('/')
      locale_from_url_path = locale_from_url_path[1] ? locale_from_url_path[1].to_sym : nil
      session[:url_locale] = locale_from_url_path
    end
    
    def set_ui_locale
      # The editor isn't fully I18n'd and might never be.
      if request.query_string.include?('view_mode=edit') || \
         (!request.xhr? && request.path_info.include?('/exercises'))
        session[:ui_locale] = I18n.default_locale
        d "00_locale: Inside editor => set UI locale to [#{session[:ui_locale]}] instead of URL-supplied locale..."
      # The viewer, on the other hand, is.
      else
        session[:ui_locale] = current_user.preferred_locale || session[:url_locale] || I18n.default_locale
        d "00_locale: Inside viewer => set UI locale to [#{session[:ui_locale]}] as requested/possible..."
      end
    end
    
    def set_content_locale
      begin
        session[:content_locale] = session[:url_locale] || I18n.default_locale
        d "00_locale: Inside viewer => set CONTENT locale to [#{session[:content_locale]}] as requested/possible..."
      rescue I18n::InvalidLocale
        d! "00_locale: User attempted to access non-existing content locale => redirecting to index..."
        redirect to('/')
      end
    end
  end
end
