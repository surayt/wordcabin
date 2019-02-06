require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application
    
    # The "keyboard demo" / "note taking mini-app", whatever.
    
    get '/keyboard' do
      haml :'keyboard', layout: false # HAML file includes its own layout
    end
  end
end
