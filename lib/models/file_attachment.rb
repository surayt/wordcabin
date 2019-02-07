require 'rack/mime'

module Wordcabin
  class FileAttachmentValidator < ActiveModel::Validator
    def validate(record)
      if record.binary_data.nil? || record.content_type.nil? || record.filename.nil?
        record.errors[:file] << I18n.t('models.file_attachment.must_be_present')
      end
    end
  end

  class FileAttachment < ActiveRecord::Base
    include ActiveModel::Validations
    validates_with FileAttachmentValidator
  
    attr_accessor :type, :tempfile, :name, :head    
    before_validation :read_tempfile_data, on: :create
    
    def read_tempfile_data
      self.binary_data = File.binread(tempfile) if tempfile
    end

    protected def extension
      ext = (Rack::Mime::MIME_TYPES.invert[content_type] || '.'+filename.split('.').last || '.')
        .gsub(/\./, '')
        .gsub('mpga', 'mp3') # What did the Rack people smoke?
      ext.blank? ? nil : ext
    end

    def url_path
      "/files/#{id}#{extension && '.'+extension}"
    end
  end
end
