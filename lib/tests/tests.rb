ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'pathname'
MAIN_CONFIG = Pathname('../../config')+'config.rb'
require_relative MAIN_CONFIG
require_relative Config.lib+'server.rb'

module SinatraApp
  class SinatraAppTest < MiniTest::Test
    include Rack::Test::Methods
    
    def app
      Server
    end
    
    def test_can_create_valid_content_fragment
      c = ContentFragment.new(locale: :de, book: 'Test')
      assert c.save
    end
    
    def test_fails_when_creating_content_fragment_without_locale
      c = ContentFragment.new(locale: nil, book: 'Test')
      assert c.save == false
    end
  end
end
