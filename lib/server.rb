#!/usr/bin/env ruby

require 'sinatra/base'
require 'sass/plugin/rack'
require 'rack/contrib'
require 'hamlit'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'bcrypt'
require 'sinatra/activerecord'
require 'sinatra/strong-params'
require 'sinatra/flash'

require_relative 'user_model'
require_relative 'content_fragment_model'

module SinatraApp 
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

    # Displaying the contents themselves.
    get '/*' do |path|
      if fragment = ContentFragment.find_by_locale_and_path(locale, path)
        @contents = fragment
      else
        cefr_level, chapter_name, heading = path.split("/")
        params[:cefr_level]   = cefr_level   || 'a1'
        params[:chapter_name] = chapter_name || 'intro'
        params[:heading]      = heading      || '1'
        content_file_name = "#{params[:cefr_level]}-#{params[:chapter_name]}.html"
        content_file = Config.cache+'chapters'+locale.to_s+content_file_name
        @contents = begin
          File.read(content_file)
        rescue
          flash[:notice] = I18n.t(:no_contents)
          String.new
        end
      end
      toc_file = Config.cache+'tocs'+"#{locale}.html"
      @toc = begin
        File.read(toc_file)
      rescue
        flash[:notice] = I18n.t(:no_toc)
        String.new
      end
      haml :contents
    end

    # Save modified contents
    post '/*' do |path|
      # TODO: Make pretty.
      begin
        if fragment = ContentFragment.find_by_path(path)
          fragment.update_attributes(params[:content_fragment])
        else
          params[:content_fragment][:path] = path
          params[:content_fragment][:locale] = locale
          ContentFragment.create(params[:content_fragment])
        end
        # TODO: i18n!
        flash[:notice] = 'The content fragment was saved successfully.'
        redirect back
      rescue
        flash[:error] = 'Oops, there was a problem saving that content fragment...'
      end
    end
  end
end
