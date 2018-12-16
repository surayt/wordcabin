class String
  # Taken from http://stackoverflow.com/questions/16328389.
  # I realize this is the slowest method. It is, however, of
  # the methods proposed at the two above URLs, also the only
  # method that worked with Ruby 2.3.
  #
  # If not inside of a module, will disturb TinyMCE uploadfile
  # plugin's interaction with the app and there'll code conversion
  # errors.
  def blank?
    strip.gsub(/ /, '').length == 0 # The gsub is a non-breakable space.
  end

  # Feels quite dirty. I've got no better idea at the moment.
  def force_utf8
    begin
      encode("utf-8").force_encoding("utf-8")
    rescue
      encode("ascii-8bit").force_encoding("utf-8")
    end
  end

  # Used for URL manipulation, mostly on "redirect back".
  def with_locale(locale)
    self.gsub /(?<=\/)([a-z]{2})(?=\/)/, locale
  end
end
