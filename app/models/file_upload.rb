class FileUpload
  include Mongoid::Document

  field :file_id, type: String
  field :size, type: Integer
  field :created_at, type: Time, default: -> { Time.now }
  field :filename, type: String
  field :content_type, type: String
  field :description, type: String
  field :tags, type: Array, default: []
  field :checksum, type: String
  field :status, type: String, default: 'uploaded'
  field :version, type: Integer, default: 1
end
