require 'colorize' # for debugging only

module Wordcabin 
  class Server < Sinatra::Application
    
    # The keyboard demo slash note taking mini-app, whatever.
    
    get '/keyboard' do
      haml :'keyboard'
    end
  end
end
