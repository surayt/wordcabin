#!/usr/bin/env ruby

require 'pathname'
require_relative Pathname('config')+'sinatra_app.rb'
require_relative Config.lib+'server.rb'
SinatraApp::Server.run!
