#!/usr/bin/env ruby

# Configuration file
require_relative '../config/config'

# Sinatra modules
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/strong-params'
require 'sinatra/flash'
require 'sinatra/activerecord'

# Runtime dependencies
require 'sprockets'
require 'hamlit' # Sinatra does know to require HAML, but not Hamlit!

# Internal dependencies
require_relative 'core/string'
require_relative 'core/object'
require_relative 'active_record/connection_adapters/sqlite3_adapter'
require_relative 'models/user'
require_relative 'models/content_fragment'
require_relative 'models/toc'
require_relative 'models/file_attachment'

module Wordcabin 
  class Server < Sinatra::Application
    
    ###########################################################################
    # Configuration                                                           #
    ###########################################################################
    
    use Rack::Session::Cookie, secret: Config.session_secret
                               #, :key => 'rack.session',
                               #  :domain => 'localhost',
                               #  :path => '/',
                               #  :expire_after => 1.year.to_i

    # Load extensions.
    register Sinatra::StrongParams
    register Sinatra::Flash
    register Sinatra::ActiveRecordExtension

    # Things only needed for development, not production.
    configure :development do
      # http://www.sinatrarb.com/contrib/reloader
      # Doesn't catch the .rb files, but is faster than rerun's
      # out-of-process reloading for templates, Coffee and SASS.
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end
    
    # Configure the application using user settings from config.rb.
    configure do
      # Stuff (I just wanted a comment here for good measure, and who reads these anyways?)
      set :server, :puma
      set :bind, Config.bind_address
      set :port, Config.bind_port
      set :root, Config.root
      set :views, Config.templates
      set :haml, {escape_html: false, format: :html5}
      set :bind, Config.bind_address
      set :port, Config.bind_port
      set :json_content_type, 'text/html' # Required by TinyMCE uploadfile plugin
      set :method_override, true # To be able to use RESTful methods
      project_root = Config.data+Config.project
      # Sprockets
      set :public_folder, Config.static_files
      set :assets, Sprockets::Environment.new(root)
      assets.append_path Config.javascripts
      assets.append_path Config.stylesheets
      assets.append_path project_root+'stylesheets'
      assets.append_path project_root+'images'
      assets.append_path project_root+'fonts'
      # Database
      if Config.database && environment != :test
        db_file = project_root+'database'+"#{Config.database}.sqlite3" 
      end
      db_file ||= Config.root+'db'+"#{environment}.sqlite3"
      puts "Configuring database #{db_file}"
      db_config = begin
        YAML.load_file(Config.config+'db.yml')[Config.database]
      rescue
        {'adapter' => 'sqlite3'}
      end
      db_config.merge!('database' => db_file.to_s)
      set :database, db_config
      # Autoprefixer
      require 'autoprefixer-rails'
      AutoprefixerRails.install(assets)
      # Internationalisation (http://recipes.sinatrarb.com/p/development/i18n)
      # Note that a locale is only considered 'available' if the corresponding
      # file in locales/*.yml contains at least one string!
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
        (User.find(session[:user_id]) if session[:user_id]) || User.new
      end
      
      def view_mode
        if params[:view_mode]
          params[:view_mode].to_sym
        else
          :preview
        end
      end

      def locale
        I18n.locale
      end
      
      def content_class
        c = []
        if current_user && current_user.is_admin? && view_mode != :preview
          c << :editor
        else
          c << :user
        end
        c << :index if request.path_info.split('/').length < 2
        c.join(' ')
      end
    end
  
    require_relative 'routes' # Yup, sometimes things are a little strange.
    run! if app_file == $0
  end
end
