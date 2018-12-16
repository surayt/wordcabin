#!/usr/bin/env ruby

require 'rack/cache'
require 'linguistics'

require_relative 'lib/server'

Linguistics.use(:en)
Rack::Cache
run Wordcabin::Server
