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
      set :root, ROOT
      set :haml, format: :html5
      # Internationalisation
      # http://recipes.sinatrarb.com/p/development/i18n
      # A locale is only considered 'available' if the
      # corresponding file in locales/*.yml contains at
      # least one string!
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.load_path = Dir[(ROOT+'locales'+'*.yml').expand_path]
      I18n.backend.load_translations
      # use Rack::Locale
      # http://stackoverflow.com/questions/3104658/how-to-detect-language-from-url-in-sinatra
      # set :locales, CONFIG[:locales]
      # set :default_locale, 'en'
      # set :locale_pattern, /^\/?(#{Regexp.union(settings.locales)})(\/.+)$/
      # CSS compiler
      Sass::Plugin.options[:style] = :compressed
      Sass::Plugin.options[:cache_location] = (Pathname(CONFIG[:cache_path])+'sass').expand_path.to_s
      Sass::Plugin.options[:template_location] = (Pathname(CONFIG[:data_path])+'template').expand_path.to_s
      Sass::Plugin.options[:css_location] = Pathname('public/stylesheets').expand_path.to_s
      use Sass::Plugin::Rack
    end

    def default_chapter(locale)
      dirs_in_locale = Pathname(CONFIG[:data_path])+'chapters'+'*'+locale
      puts dirs_in_locale
      #puts Dir.glob(dirs_in_locale).inspect
    end

=begin
    helpers do
      def locale
        @locale || settings.default_locale
      end
    end

    before do
      @locale, request.path_info = $1, $2 if request.path_info =~ settings.locale_pattern
    end
=end

    before '/:locale/?*' do
      I18n.locale = params[:locale]
      request.path_info = '/'+params[:splat].first
    end

    get '/' do
      @locales = I18n.available_locales
      haml :list_languages
    end

    get '/*' do |splat|
      @locale = I18n.locale
      cefr_level, chapter, heading = splat.split("/")
      params[:cefr_level] = cefr_level || 'a1'
      params[:chapter]    = chapter    || 'intro'
      params[:heading]    = heading    || '1'
      haml :show_contents
    end
  end
end
