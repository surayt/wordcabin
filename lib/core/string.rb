# Taken from http://stackoverflow.com/questions/16328389,
# respectively from https://bugs.ruby-lang.org/issues/8206

# I realize this is the slowest method. It is, however, of
# the methods proposed at the two above URLs, also the only
# method that worked with Ruby 2.3.
class String
  def blank?
    strip.length == 0
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end
