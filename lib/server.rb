#!/usr/bin/env ruby

require 'sinatra/base'
require 'sass/plugin/rack'
require 'rack/contrib'
require 'haml'
require 'i18n'
require 'i18n/backend/fallbacks'

module Textbookr
  class Server < Sinatra::Base
    configure do
      set :environment, :development
      set :root, Config.root_path
      set :haml, format: :html5
      # Internationalisation
      # http://recipes.sinatrarb.com/p/development/i18n
      # A locale is only considered 'available' if the
      # corresponding file in locales/*.yml contains at
      # least one string!
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.load_path = Dir[Config.root_path+'locales'+'*.yml']
      I18n.backend.load_translations
      # use Rack::Locale # TODO: Fix this so that it does not inject region as well!
      # CSS compiler
      Sass::Plugin.options[:style] = :compressed
      Sass::Plugin.options[:cache_location] = (Config.cache_path+'sass').to_s
      Sass::Plugin.options[:template_location] = (Config.data_path+'template').to_s
      Sass::Plugin.options[:css_location] = (Config.public_path+'stylesheets').to_s
      use Sass::Plugin::Rack
    end

    # Prepending the rest of the route with the locale code
    before '/:locale/?*' do
      I18n.locale = params[:locale]
      request.path_info = '/'+params[:splat].first
    end

    # Landung page showing the list of available L1s
    get '/' do
      @locales = I18n.available_locales
      haml :list_languages
    end

    # Displaying the contents themselves
    get '/*' do |splat|
      @locale = I18n.locale
      cefr_level, chapter_name, heading = splat.split("/")
      params[:cefr_level]   = cefr_level   || 'a1'
      params[:chapter_name] = chapter_name || 'intro'
      params[:heading]      = heading      || '1'
      content_file_name = "#{params[:cefr_level]}-#{params[:chapter_name]}.html"
      content_file = Config.cache_path+'chapters'+@locale.to_s+content_file_name
      @contents = begin
        File.read(content_file)
      rescue
        I18n.t(:no_contents)
      end
      haml :show_contents
    end
  end
end
