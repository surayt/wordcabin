#!/usr/bin/env ruby

require 'pathname'
require 'rack/cache'
require 'sprockets'

require_relative Pathname('config')+'config.rb'
require_relative Config.lib+'server.rb'

use Rack::Cache
SinatraApp::Server.run!
