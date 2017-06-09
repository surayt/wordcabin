#!/usr/bin/env ruby

require 'sinatra/base'
require 'sass/plugin/rack'
require 'rack/contrib'
require 'hamlit'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'bcrypt'
require 'sinatra/activerecord'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'sinatra/strong-params'
require 'sinatra/flash'
require 'nokogiri'

require_relative 'user_model'
require_relative 'content_fragment_model'

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
  
    # Load extensions.
    register Sinatra::ActiveRecordExtension
    register Sinatra::StrongParams
    register Sinatra::Flash
    # Configure the application using user settings from config.rb.
    configure do
      set :environment, Config.environment
      set :root, Config.root
      set :views, Config.haml
      set :haml, {escape_html: false, format: :html5}
      set :bind, Config.bind_address
      set :port, Config.bind_port
      set :sessions, true
      # Internationalisation
      # http://recipes.sinatrarb.com/p/development/i18n
      # A locale is only considered 'available' if the
      # corresponding file in locales/*.yml contains at
      # least one string!
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.load_path = Dir[Config.locales+'*.yml']
      I18n.backend.load_translations
      # CSS compiler
      Sass::Plugin.options[:style] = :expanded
      Sass::Plugin.options[:cache_location] = (Config.cache+'sass').to_s
      Sass::Plugin.options[:template_location] = (Config.sass).to_s
      Sass::Plugin.options[:css_location] = (Config.css).to_s
      use Sass::Plugin::Rack
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
    end

    # Internal helpers

    def build_toc
      fragment = Nokogiri::HTML::Builder.new do |doc|
        books = ContentFragment.where(locale: locale, chapter: '').order(:book).uniq
        doc.ul {
          books.each { |book|
            doc.li(class: 'level_1') {
              doc.a(href: book.path) { doc.text book.heading }
              # recurse_chapters
            }
          }
        }
      end
      @toc = fragment.to_html
    end
    
    ###########################################################################
    # Routes                                                                  #
    ###########################################################################

    # Prepending the rest of the route with the locale code.
    before '/:locale/?*' do
      pass if request.path_info.match /^\/javascripts/
      I18n.locale = params[:locale]
      request.path_info = '/'+params[:splat].first
    end

    # Compiled CoffeeScript
    # https://jaketrent.com/post/serve-coffeescript-with-sinatra/
    get '/javascripts/*.js' do
      filename = params[:splat].first
      fullpath = (Config.coffee+filename).to_s
      coffee fullpath.to_sym # Weird quirk that it must be a symbol...
    end
    
    # Landing page showing the list of available L1s.
    get '/' do
      @locales = I18n.available_locales
      haml :language_list
    end

    # Handling logging in and logging out.

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
          redirect to(params[:referer] || '/')
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

    # Display contents
    
    get '/new' do
      book = params[:content_fragment][:book] if params[:content_fragment]
      @contents = ContentFragment.new(book: book || '')
      build_toc
      haml :contents
    end

    get '/:book' do |book|
      @contents = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, '')
      @contents ||= ContentFragment.new(locale: locale, book: book)
      build_toc
      haml :contents
    end

    get '/:book/:chapter' do |book, chapter|
      @contents = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, chapter)
      @contents ||= ContentFragment.new(locale: locale, book: book, chapter: chapter)
      build_toc
      haml :contents
    end

    # Save modified contents
    
    post '/new' do
      params[:content_fragment].merge!(locale: locale)
      fragment = ContentFragment.create(params[:content_fragment])
      redirect fragment.path
    end
    
    post '/:book' do |book|
      fragment = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, '')
      if fragment.update_attributes(params[:content_fragment])
        flash[:notice] = 'The content fragment was saved successfully.'
      else
        flash[:error] = 'Oops, there was a problem saving that content fragment...'
      end
      redirect back
    end

    post '/:book/:chapter' do |book, chapter|
      fragment = ContentFragment.find_by_locale_and_book_and_chapter(locale, book, chapter)
      if fragment.update_attributes(params[:content_fragment])
        flash[:notice] = 'The content fragment was saved successfully.'
      else
        flash[:error] = 'Oops, there was a problem saving that content fragment...'
      end
      redirect back
    end
  end
end
