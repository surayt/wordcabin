# debug tooling

require 'colorize'

def d(s)
  puts s.green
end

def d?(s)
  puts s.yellow
end

def d!(s)
  puts s.red
end
