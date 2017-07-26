###############
# Leave alone #
###############

require 'colorize'
require 'pathname'
require 'ostruct'
c={root: Pathname(__FILE__).dirname.parent.expand_path};r=c[:root]
Config=OpenStruct.new(c.merge({

################################
# Edit below to fit your needs #
################################

environment:    'development', # Either development or production
bind_address:   'localhost',   # Use 0.0.0.0 to bind to all interfaces, IP or hostname can be specified
bind_port:      4567,          # Ports below 1024 will require root access, default would be 4567
session_secret: "we'll leave it at this during development...",

# Important paths follow

data:         r+'data'+'aop',
media:        r+'data'+'aop'+'template',
lib:          r+'lib',
legacy_media: r+'public'+'media',
translations: r+'locales',
templates:    r+'templates',
stylesheets:  r+'stylesheets',
javascripts:  r+'javascripts',
static_files: r+'public'

#####################
# Leave alone again #
#####################

}))
