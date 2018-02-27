require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application

    # Serve assets through Sprockets
   
    get '/assets/*' do
      env["PATH_INFO"].sub!('/assets', '')
      settings.assets.call(env)
    end
  end
end
