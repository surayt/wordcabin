###############
# Leave alone #
###############

require 'pathname'
require 'ostruct'
c = {root: Pathname(__FILE__).dirname.parent.expand_path}
Config = OpenStruct.new(c.merge({

######################################
# Edit below to fit your environment #
######################################

environment:  'development', # Either development or production
bind_address: '0.0.0.0', # 0.0.0.0 to bind to all interfaces, otherwise the if's IP
bind_port:    4567,
# Important paths follow
data:         c[:root]+'data'+'aop',
media:        c[:root]+'data'+'aop'+'template',
cache:        c[:root]+'cache',
lib:          c[:root]+'lib',
templates:    c[:root]+'templates',
haml:         c[:root]+'templates'+'html',
sass:         c[:root]+'templates'+'stylesheets',
coffee:       Pathname('../javascripts'), # Must be relative to haml path
static:       c[:root]+'public',
css:          c[:root]+'public'+'stylesheets',
javascript:   c[:root]+'public'+'javascripts',
legacy_media: c[:root]+'public'+'media',
locales:      c[:root]+'locales'

###############
# Leave alone #
###############

}))
