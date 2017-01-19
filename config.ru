#!/usr/bin/env ruby

require 'pathname'
require_relative 'config.rb'
require_relative Config.lib_path+'server.rb'
Textbookr::Server.run!
