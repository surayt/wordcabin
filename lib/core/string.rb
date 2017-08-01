module Wordcabin
  # Taken from http://stackoverflow.com/questions/16328389.
  # I realize this is the slowest method. It is, however, of
  # the methods proposed at the two above URLs, also the only
  # method that worked with Ruby 2.3.
  class String
    def blank?
      strip.length == 0
    end
  end
end
