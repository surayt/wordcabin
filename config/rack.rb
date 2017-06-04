#!/usr/bin/env ruby

require 'pathname'
require_relative 'app.rb'
require_relative Config.lib_path+'server.rb'
Textbookr::Server.run!
