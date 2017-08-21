class String
  # Taken from http://stackoverflow.com/questions/16328389.
  # I realize this is the slowest method. It is, however, of
  # the methods proposed at the two above URLs, also the only
  # method that worked with Ruby 2.3.
  def blank?
    strip.gsub(/ /, '').length == 0
  end
  
  # Feels quite dirty. I've got no better idea at the moment.
  def force_utf8
    begin
      encode("utf-8").force_encoding("utf-8")
    rescue
      encode("ascii-8bit").force_encoding("utf-8")
    end
  end
end
