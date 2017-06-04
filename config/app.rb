require 'pathname'
require 'ostruct'
c = {root_path: Pathname(__FILE__).dirname.parent.expand_path}

# Edit below to fit your environment
Config = OpenStruct.new(c.merge({
  data_path:     c[:root_path]+'data'+'aop',
  template_path: c[:root_path]+'data'+'aop'+'template',
  # database:      {adapter: 'sqlite3', database: c[:root_path]+'data'+'aop'+'development.sqlite3'},
  cache_path:    c[:root_path]+'cache',
  lib_path:      c[:root_path]+'lib',
  public_path:   c[:root_path]+'public',
  sass_path:     c[:root_path]+'public'+'stylesheets'+'sass',
  css_path:      c[:root_path]+'public'+'stylesheets',
}))
