#!/usr/bin/env ruby

require 'pathname'
require 'rack/cache'
require 'sprockets'
require 'colorize'
require 'semantic_logger'

require_relative Pathname('config')+'config.rb'
require_relative Config.lib+'server.rb'

SemanticLogger.default_level = :trace
SemanticLogger.add_appender(file_name: "#{Config.environment}.log", formatter: :color)

Rack::Cache
SinatraApp::Server.run!
