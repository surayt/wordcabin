#!/usr/bin/env ruby

require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/strong-params'
require 'sinatra/flash'
require 'sinatra/activerecord'
require 'sinatra/reloader'

require 'hamlit'

# TODO: Figure out which of these can be removed
# (some are already require'd by Sinatra modules above)
require 'logger'
require 'sprockets'
require 'json'
require 'sass'
require 'sass/plugin/rack'
require 'uglifier'
require 'coffee-script'
require 'execjs'
require 'rack/contrib'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'bcrypt'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'nokogiri'

require_relative 'models/user'
require_relative 'models/content_fragment'
require_relative 'models/toc'
require_relative 'models/file_attachment'

module SinatraApp 
  # Adapted from http://joeyates.info/2010/01/31/regular-expressions-in-sqlite/
  # Implements SQLite's REGEXP function in Ruby (like the commandline client's 'pcre' extension)
  class ActiveRecord::ConnectionAdapters::SQLite3Adapter
    def initialize(connection, logger, connection_options, config) # (db, logger, config)
      # Verbatim from https://github.com/rails/rails/blob/e2e63770f59ce4585944447ee237ec722761e77d/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb
      super(connection, logger, config)
      @active     = nil
      @statements = StatementPool.new(self.class.type_cast_config_to_integer(config[:statement_limit]))
      configure_connection
      # Unchanged from source
      connection.create_function('regexp', 2) do |func, pattern, expression|
         regexp = Regexp.new(pattern.to_s, Regexp::IGNORECASE)
         if expression.to_s.match(regexp)
           func.result = 1
         else
           func.result = 0
         end
       end
    end
  end

  class Server < Sinatra::Base
    ###########################################################################
    # Configuration                                                           #
    ###########################################################################
    use Rack::Session::Cookie, secret: "we'll leave it at this during development..."
                              #, :key => 'rack.session',
                              #  :domain => 'localhost',
                              #  :path => '/',
                              #  :expire_after => 1.year.to_i,
                              #  :secret => "TODO: use something sensible!"

    # Load extensions.
    register Sinatra::ActiveRecordExtension
    register Sinatra::StrongParams
    register Sinatra::Flash

    # Things only needed for development, not production.
    configure :development do
      # It's simple. It works. Leave me alone.
      $logger = Logger.new('development.log')
      # Doesn't recognize all changes but should be good enough.
      register Sinatra::Reloader
      also_reload Config.lib+"*/*.rb"
      after_reload {$logger.info('reloaded')}
      set :reload_templates, true
      enable :reloader # Should not be needed ... meh.
    end
    
    # Configure the application using user settings from config.rb.
    configure do
      # Stuff (I just wanted a comment here for good looks)
      set :environment, Config.environment
      set :root, Config.root
      set :views, Config.templates
      set :haml, {escape_html: false, format: :html5}
      set :bind, Config.bind_address
      set :port, Config.bind_port
      set :json_content_type, 'text/html' # Required by TinyMCE uploadfile plugin
      set :method_override, true # To be able to use RESTful methods
      set :public_folder, Config.static_files
      # Sprockets
      set :assets, Sprockets::Environment.new(root)
      assets.append_path Config.javascripts
      assets.append_path Config.stylesheets
      # Internationalisation
      # http://recipes.sinatrarb.com/p/development/i18n
      # A locale is only considered 'available' if the
      # corresponding file in locales/*.yml contains at
      # least one string!
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.load_path = Dir[Config.translations+'*.yml']
      I18n.backend.load_translations
    end
    
    ###########################################################################
    # Helper Methods                                                          #
    ###########################################################################

    helpers do
      # Just some convenience (nicer to type current_user in views, etc.)
      def current_user
        User.find(session[:user_id]) if session[:user_id]
      end

      def locale
        I18n.locale
      end
      
      def content_class
        c = []
        if current_user && current_user.is_admin? && params[:view_mode] != 'preview'
          c << :editor
        else
          c << :user
        end
        c << :language_list if request.path_info.split('/').length < 2
        c.length > 0 ? c.join(' ') : nil
      end
      
      def first_content_fragment(_locale)
        if fragment = @first_content_fragment.where(locale: _locale).first
          fragment.book
        else
          'New book or language version' # TODO: i18n!
        end
      end
    end
    
    ###########################################################################
    # Routes                                                                  #
    ###########################################################################

    # Prepend all routes with locale info, but skip asset route
    before '/:locale/?*' do
      pass if request.path_info.match /^\/assets/
      I18n.locale = params[:locale]
      request.path_info = '/'+params[:splat].first
    end
    # Serve assets through Sprockets
    get '/assets/*' do
      env["PATH_INFO"].sub!('/assets', '')
      settings.assets.call(env)
    end
    
    # Landing page showing the list of available L1s.
    get '/' do
      @locales = I18n.available_locales
      @first_content_fragment = ContentFragment.where(chapter: '').order(:book)
      haml :language_list
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
      file = FileAttachment.find(id)
      headers['Content-Type'] = file.content_type
      file.binary_data
    end
    post '/upload' do
      begin
        params[:document][:file][:content_type] = params[:document][:file][:type]
        file = FileAttachment.new(params[:document][:file])
        if file.save
          $logger.info(file.inspect)
          url  = "/#{locale}/files/#{file.id}"
          url += ".#{file.extension}" if file.extension
          json(document: {
            url: url,
            title: params['document']['title']
          })
        else
          $logger.warn(file.errors.full_messages.first)
          json(error: {message: file.errors.full_messages.first})
        end
      rescue => e
        $logger.warn(e.inspect)
        json(error: {message: e.inspect})
      end
    end

    # Display contents
    get '/new' do
      book = params[:content_fragment][:book] if params[:content_fragment]
      @contents = ContentFragment.new(params[:content_fragment])
      @toc = TOC.new(locale)
      haml :contents
    end
    get '/:book' do |book|
      @contents = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, '')
      @contents ||= ContentFragment.new(locale: locale, book: book)
      @toc = TOC.new(locale, book)
      haml :contents
    end
    get '/:book/:chapter' do |book, chapter|
      @contents = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, chapter)
      @contents ||= ContentFragment.new(locale: locale, book: book, chapter: chapter)
      @toc = TOC.new(locale, book)
      haml :contents, layout: !request.xhr?
    end

    # Save modified contents
    post '/new' do
      params[:content_fragment].merge!(locale: locale)
      fragment = ContentFragment.new(params[:content_fragment])
      if fragment.save
        redirect to(URI.escape(fragment.path))
      else
        flash[:error] = fragment.errors.to_a.last # We shall content ourselves with showing one error.
        redirect back
      end
    end
    post '/:book' do |book|
      unless fragment = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, '')
        params[:content_fragment].merge!(locale: locale)
        fragment = ContentFragment.create(params[:content_fragment])
      end
      if fragment.update_attributes(params[:content_fragment])
        flash[:notice] = 'The content fragment was saved successfully.'
      else
        flash[:error] = fragment.errors.to_a.last
      end
      redirect back
    end
    post '/:book/:chapter' do |book, chapter|
      unless fragment = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, chapter)
        params[:content_fragment].merge!(locale: locale)
        fragment = ContentFragment.create(params[:content_fragment])
      end
      if fragment.update_attributes(params[:content_fragment])
        flash[:notice] = 'The content fragment was saved successfully.'
      else
        flash[:error] = fragment.errors.to_a.last
      end
      redirect back
    end
    
    # Trash, obliterate and destroy contents
    delete '/:book' do |book|
      if fragment = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, '')
        if fragment.destroy
          flash[:notice] = 'The content fragment was destroyed successfully.'
        else
          flash[:error] = 'Unable to delete content fragment!'
        end
      end
      redirect to('/')
    end
    delete '/:book/:chapter' do |book, chapter|
      if fragment = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, chapter)
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
