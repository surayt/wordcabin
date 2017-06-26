require 'rack/mime'

module SinatraApp
  class FileAttachment < ActiveRecord::Base
    validates :binary_data, :content_type, presence: {message: 'must be present.'} # TODO: i18n!
  
    attr_accessor :type, :tempfile, :name, :head    
    before_validation :read_tempfile_data, on: :create
    
    def read_tempfile_data
      self.binary_data = File.binread(tempfile)
    end
    
    def extension
      Rack::Mime::MIME_TYPES.invert[content_type] || filename.split('.').last || nil
    end
  end
end
