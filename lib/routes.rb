module SinatraApp
  class Server < Sinatra::Application
    include SemanticLogger::Loggable
    
    # Prepend all routes with locale info, but skip locale-independent ones
    
    before '/:locale/?*' do
      pass if request.path_info.match(/^\/(assets|files)/)
      begin
        I18n.locale = params[:locale]
        request.path_info = "/#{params[:splat].first}"
      rescue I18n::InvalidLocale
        # TODO: i18n!
        flash[:error] = "The address you tried to access is not accessible without providing a locale."
        redirect to('/')
      end
    end
    
    # Serve assets through Sprockets
   
    get '/assets/*' do
      env["PATH_INFO"].sub!('/assets', '')
      settings.assets.call(env)
    end
    
    # Landing page showing the list of available L1s.
    
    get '/' do
      @fragments = ContentFragment.empty_chapters
      if !@fragments.any? && current_user.is_admin?
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

    # FileAttachment
    
    get '/files/:id.?:extension?' do |id,ext| # second one is unused
      begin
        file = FileAttachment.find(id)
        headers['Content-Type'] = file.content_type
        file.binary_data
      rescue ActiveRecord::RecordNotFound
        flash[:warning] = "One of the attached files could not be found."
      end
    end
    
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

    # ContentFragment routes. Careful with these as their order is important!
    
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
        request.xhr? ? haml(:article, layout: false) : haml(:contents)
      else
        flash[:error] = "We're sorry, there's no such chapter in this book." # TODO: i18n!
        redirect to('/')
      end
    end
    
    get '/:book' do |book|
      book = ContentFragment.book(locale, book)
      if book.first_child
        location = book.first_child.url_path
      else
        if current_user.is_admin?
          location = "/#{locale}/new?content_fragment[book]=#{book.book}&view_mode=edit"
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
        params[:content_fragment].merge!(locale: locale)
        @fragment = ContentFragment.new(params[:content_fragment])
      else
        @fragment = ContentFragment.find(id)
        @fragment.update_attributes(params[:content_fragment])
      end
      if @fragment
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
  end
end
