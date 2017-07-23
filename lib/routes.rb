module SinatraApp
  class Server < Sinatra::Base
    # Prepend all routes with locale info, but skip locale-independent ones
    
    before '/:locale/?*' do
      pass if request.path_info.match(/^\/(assets|files)/)
      begin
        I18n.locale = params[:locale]
        request.path_info = '/'+params[:splat].first
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
      @books = ContentFragment.empty_chapter
      if !@books.any? && current_user.is_admin?
        redirect to("/#{locale}/new")
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

    # Deal with audio/video files, etc.
    
    get '/files/:id.?:extension?' do |id,ext| # second one is unused
      begin
        file = FileAttachment.find(id)
        headers['Content-Type'] = file.content_type
        file.binary_data
      rescue ActiveRecord::RecordNotFound
        flash[:warning] = "One of the attached files could not be found."
      end
    end
    
    post '/files/upload' do
      begin
        params[:document][:file][:content_type] = params[:document][:file][:type]
        file = FileAttachment.new(params[:document][:file])
        if file.save
          $logger.info(file.inspect)
          json(document: {
            url: file.url_path,
            title: params['document']['title']
          })
        else
          msg = file.errors.full_messages.first
          $logger.warn(msg)
          json(error: {message: msg})
        end
      rescue => e
        msg = "Internal server error in /files/upload (#{e})"
        $logger.warn(msg)
        json(error: {message: msg})
      end
    end

    # Display contents
    
    get '/new' do
      book = ContentFragment.book(locale, params[:content_fragment][:book]).first if params[:content_fragment]
      @contents = ContentFragment.new(params[:content_fragment])
      @toc = TOC.new(locale, book)
      haml :contents
    end
    
    get '/:book' do |book|
      @contents = ContentFragment.book(locale, book).first
      @contents ||= ContentFragment.new(locale: locale, book: book)
      @toc = TOC.new(locale, @contents)
      haml :contents
    end
    
    get '/:book/:chapter' do |book, chapter|
      @contents = ContentFragment.chapter(locale, book, chapter).first
      @contents ||= ContentFragment.new(locale: locale, book: book, chapter: chapter)
      @toc = TOC.new(locale, @contents.parent)
      haml :contents, layout: !request.xhr?
    end

    # Save modified contents
    
    post '/new' do
      params[:content_fragment].merge!(locale: locale)
      $logger.warn "these were the params: #{params[:content_fragment].inspect}"
      @contents = ContentFragment.new(params[:content_fragment])
      if @contents.save
        redirect to(URI.escape(@contents.url_path)+"?view_mode=preview")
      else
        flash[:error] = @contents.errors.full_messages.join(" ") # Not pretty, but whatever.
        redirect back
      end
    end
    
    post '/:book' do |book|
      unless fragment = ContentFragment.book(locale, book).first
        params[:content_fragment].merge!(locale: locale)
        fragment = ContentFragment.create(params[:content_fragment])
      end
      if fragment.update_attributes(params[:content_fragment])
        redirect to(URI.escape(fragment.url_path)+"?view_mode=preview")
        flash[:notice] = 'The content fragment was saved successfully.'
      else
        flash[:error] = fragment.errors.to_a.last
        redirect back
      end
    end
    
    post '/:book/:chapter' do |book, chapter|
      unless fragment = ContentFragment.chapter(locale, book, chapter).first
        params[:content_fragment].merge!(locale: locale)
        fragment = ContentFragment.create(params[:content_fragment])
      end
      if fragment.update_attributes(params[:content_fragment])
        redirect to(URI.escape(fragment.url_path)+"?view_mode=preview")
        flash[:notice] = 'The content fragment was saved successfully.'
      else
        flash[:error] = fragment.errors.to_a.last
        redirect back
      end
    end
    
    # Trash, obliterate and destroy contents
    
    delete '/:book' do |book|
      if fragment = ContentFragment.book(locale, book).first
        if fragment.destroy
          flash[:notice] = 'The content fragment was destroyed successfully.'
        else
          flash[:error] = 'Unable to delete content fragment!'
        end
      end
      redirect to('/')
    end
    
    delete '/:book/:chapter' do |book, chapter|
      if fragment = ContentFragment.book(locale, book).first
        if fragment.destroy
          flash[:notice] = 'The content fragment was destroyed successfully.'
        else
          flash[:error] = 'Unable to delete content fragment!'
        end
      end
      redirect back
    end  
  end
end
