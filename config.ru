#!/usr/bin/env ruby

require 'rack/cache'
require_relative 'lib/server'

Rack::Cache
run Wordcabin::Server
