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
        puts "attempted access to non-existing content locale #{params[:locale].inspect}".red # logger.debug
        redirect to('/')
      end
    end
    
    # Prepend all routes with locale info, but skip locale-independent ones
    # Static routes (i.e., any file inside of public/) never arrive here anyways
    
    before '/:locale/?*' do
      pass if %w{assets files favicon.ico __sinatra__}.include? params[:locale]
      request.path_info = "/#{params[:splat].first}"
    end
    
    # Serve assets through Sprockets
   
    get '/assets/*' do
      env["PATH_INFO"].sub!('/assets', '')
      settings.assets.call(env)
    end
    
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

    # Handle logging in and logging out.
    
    get '/login' do
      @user = User.new
      haml :login_form
    end
    
    post '/login' do
      # TODO: What about strong params?
      if @user = User.find_by_email(params[:user_email])
        if @user.authenticate(params[:user_password])
          session[:user_id] = @user.id
          # TODO: i18n!
          flash[:notice] = "Welcome, #{current_user.email.split('@').first}!"
          redirect to(URI.escape(params[:referer]) || '/') # The referer may and *will* contain special characters!
        end
      end
      # TODO: i18n!
      flash[:error] = 'Sorry, email address or password must have been incorrect.'
      redirect back
    end
    
    get '/logout' do
      current_user && session[:user_id] = nil
      # TODO: i18n!
      flash[:notice] = "Your session has been closed."
      redirect back
    end

    # FileAttachment routes. Must come before ContentFragment routes.
    
    get '/files/:id.?:extension?' do |id,ext| # second one is unused
      begin
        file = FileAttachment.find(id)
        headers['Content-Type'] = file.content_type
        file.binary_data
      rescue ActiveRecord::RecordNotFound
        flash[:warning] = "One of the attached files could not be found."
      end
    end
    
    # TODO: Uploads sind kaputt - incompatible encoding regexp match (UTF-8 regexp with ASCII-8BIT string)
    post '/files' do
      begin
        params[:document][:file][:content_type] = params[:document][:file][:type]
        file = FileAttachment.new(params[:document][:file])
        if file.save
          json(document: {
            url: file.url_path,
            title: params['document']['title']
          })
        else
          msg = file.errors.full_messages.first
          json(error: {message: msg})
        end
      rescue => e
        msg = "Internal server error in /files/upload (#{e})"
        json(error: {message: msg})
      end
    end
    
    # Exercise routes. Must come before ContentFragment routes.
    
    get '/exercises' do
      if current_user.is_admin?
        @exercises = Exercise.all
        haml :exercises
      else
        redirect to('/')
      end
    end
    
    # TODO: find out why Sinatra can't recognize XHR requests
    # and re-integrate this tidbit with the regular one above.
    # First hints: HTTP_X_REQUESTED_WITH is lacking from both
    # headers{} and env{}.
    get '/exercises.json' do
      if current_user.is_admin?
        Exercise.all.map {|e| {text: e.name, value: e.id}}.to_json
      end
    end
    
    get '/exercises/:id' do |id|
      @exercises = Exercise.all
      @exercise = @exercises.find(id)
      @text_fragments = @exercise.text_fragments
      @questions = @exercise.questions
      haml @exercise.template_name.to_sym, layout: false
    end

    # ContentFragment routes. Must come last. And careful with these as their order is important!
    
    get /\/(new|(.*)\/(.*))/ do
      __new__, book, chapter = params['captures']
      if book && chapter
        @fragment = ContentFragment.chapter(locale, book, chapter)
      else
        params[:content_fragment] ||= {}
        params[:content_fragment][:locale] = locale
        @fragment = ContentFragment.new(params[:content_fragment])
      end
      if @fragment
        @toc = TOC.new(locale, @fragment.parent)
        # TODO: the below condition always returns `false'. Find out why
        # Sinatra is unable to recognize XHR requests and then fix up the
        # JavaScript that is _supposed_ to parse JSON, but is no parsing
        # HTML instead...
        request.xhr? ? haml(:article, layout: false) : haml(:contents)
      else
        flash[:error] = "We're sorry, there's no such chapter in this book." # TODO: i18n!
        redirect to('/')
      end
    end
    
    get '/:book' do |book|
      book = ContentFragment.book(locale, book)
      if book && book.first_child
        location = book.first_child.url_path
      else
        if current_user.is_admin?
          location = "/#{locale}/new?content_fragment[book]=#{book.book}&content_fragment[locale]=#{book.locale}&view_mode=edit"
        else
          flash[:warn] = 'The selected book is empty, please check back later.' # TODO: i18n!
          location = '/'
        end
      end
      redirect to(location)
    end
    
    post /\/(new|(.*))/ do
      __new__, id = params['captures']
      if __new__ && __new__ == 'new'
        params[:content_fragment].merge!(locale: locale) if params[:content_fragment][:locale].blank?
        @fragment = ContentFragment.new(params[:content_fragment])
      else
        @fragment = ContentFragment.find(id)
        @fragment.update_attributes(params[:content_fragment])
      end
      if @fragment
        if published = params[:parent_is_published]
          @fragment.parent.update_attribute(:is_published, published == 'true' ? true : false)
        end
        if @fragment.save
          flash[:notice] = 'The content fragment was saved successfully.' # TODO: i18n!
          redirect to("#{URI.escape(@fragment.url_path)}?view_mode=preview")
        else
          flash[:error] = @fragment.errors.full_messages.join(' ') # Not pretty, but whatever.
          redirect back
        end
      else
        flash[:error] = 'No such content fragment could be found.' # TODO: i18n!
        redirect back
      end
    end
    
    delete '/:id' do |id|
      if @fragment = ContentFragment.find(id)
        if @fragment.destroy
          flash[:notice] = 'The content fragment was destroyed successfully.' # TODO: i18n!
        else
          flash[:error] = 'Unable to delete content fragment!' # TODO: i18n!
        end
      else
        flash[:error] = 'No such content fragment could be found.' # TODO: i18n!
      end
      redirect back
    end
    
    private
    
    def extract_locale_from_accept_language_header
      if accept_lang = request.env['HTTP_ACCEPT_LANGUAGE']
        accept_lang.scan(/^[a-z]{2}/).first
      else
        I18n.default_locale
      end  
    end
  end  
end
