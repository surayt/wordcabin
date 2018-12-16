module Wordcabin
  class User < ActiveRecord::Base
    # http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
    has_secure_password # Model now knows how to populate the 'password_digest' field when a 'password' parameter is specified.
                        # There is also an 'authenticate' method taking one argument (the password) and returning false or a User object.

    validates :email, uniqueness: true
  end
end
