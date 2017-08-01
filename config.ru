#!/usr/bin/env ruby

require 'pathname'
require 'rack/cache'
require 'sprockets'
require 'semantic_logger'

require_relative Pathname('config')+'config.rb'
require_relative Config.lib+'server.rb'

SemanticLogger.default_level = :trace
SemanticLogger.add_appender(file_name: "#{Config.environment}.log", formatter: :color)

Rack::Cache
run SinatraApp::Server.run!
