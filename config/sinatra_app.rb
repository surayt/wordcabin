###############
# Leave alone #
###############

require 'pathname'
require 'ostruct'
c={root: Pathname(__FILE__).dirname.parent.expand_path};r=c[:root]
Config=OpenStruct.new(c.merge({

################################
# Edit below to fit your needs #
################################

environment:  'development', # Either development or production
bind_address: '0.0.0.0',     # Use 0.0.0.0 to bind to all interfaces, otherwise the interface's IP address
bind_port:    4567,          # Ports below 1024 will require root access, default is 4567

# Important paths follow

data:         r+'data'+'aop',
media:        r+'data'+'aop'+'template',
lib:          r+'lib',
legacy_media: r+'public'+'media',
translations: r+'locales',
templates:    r+'views',
stylesheets:  r+'stylesheets',
javascripts:  r+'javascripts',
static_files: r+'public'

#####################
# Leave alone again #
#####################

}))
