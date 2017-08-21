# Taken from https://bugs.ruby-lang.org/issues/8206.
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end
