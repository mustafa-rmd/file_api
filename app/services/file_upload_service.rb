# app/services/file_upload_service.rb
class FileUploadService
  # Interface for file upload operations
  def self.upload_file(file_data, original_filename)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def self.get_all_files
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def self.get_file(id)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def self.delete_file(id)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
