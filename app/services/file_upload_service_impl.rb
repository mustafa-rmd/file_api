# app/services/file_upload_service_impl.rb
require "mime/types"
require_relative "../../app/models/dto/file_upload_dto"

class FileUploadServiceImpl
  LOG_PREFIX = "[FileUploadServiceImpl]"
  BUCKET_NAME = "file"

  def self.upload_file(file_data, original_filename)
    Rails.logger.info("#{LOG_PREFIX} Starting file upload for: #{original_filename}")

    # Generate a unique file ID
    file_id = SecureRandom.uuid
    # Determine the content type
    content_type = determine_content_type(original_filename)

    # Check if the bucket exists before putting the object
    begin
      # Attempt to check if the bucket exists
      S3_CLIENT.head_bucket(bucket: BUCKET_NAME)
      Rails.logger.info("#{LOG_PREFIX} Bucket #{BUCKET_NAME} exists.")

    rescue Aws::S3::Errors::NotFound
      # If the bucket does not exist, create it
      Rails.logger.info("#{LOG_PREFIX} Bucket #{BUCKET_NAME} does not exist. Creating it...")

      S3_CLIENT.create_bucket(bucket: BUCKET_NAME)
      Rails.logger.info("#{LOG_PREFIX} Bucket #{BUCKET_NAME} created successfully.")

    rescue Aws::S3::Errors::ServiceError => e
      # Handle other S3-related service errors
      Rails.logger.error("#{LOG_PREFIX} An error occurred: #{e.message}")
      # Optionally, you can continue execution or raise the error based on your requirements
    end

    S3_CLIENT.put_object(
      bucket: BUCKET_NAME,
      key: file_id,
      body: file_data,
      content_type: content_type
    )

    Rails.logger.info("#{LOG_PREFIX} File uploaded successfully with ID: #{file_id}")

    file_upload = FileUpload.new
    file_upload.file_id = file_id
    file_upload.size = file_data.bytesize
    file_upload.filename = original_filename
    file_upload.content_type = determine_content_type(original_filename)
    file_upload.description = generate_description(original_filename)
    file_upload.tags = generate_tags(original_filename)
    file_upload.checksum = Digest::MD5.hexdigest(file_data)
    file_upload.status = "uploaded"


    if file_upload.save
      Rails.logger.info("#{LOG_PREFIX} File uploaded successfully with ID: #{file_upload.file_id}")
      FileUploadDTO.new(
        file_upload.file_id,
        Base64.encode64(file_data),
        file_upload.size,
        file_upload.created_at.iso8601
      ).to_h
    else
      Rails.logger.error("#{LOG_PREFIX} File upload failed for: #{original_filename}, Errors: #{file_upload.errors.full_messages.join(", ")}")
      raise ActiveRecord::RecordInvalid.new(file_upload)
    end
  end


  def self.get_all_files
    Rails.logger.info("#{LOG_PREFIX} Fetching all files")

    begin
      # List all objects in the bucket
      objects = S3_CLIENT.list_objects_v2(bucket: BUCKET_NAME).contents

      # Fetch all file uploads from MongoDB
      file_uploads = FileUpload.all.to_a

      # Create a hash for quick lookup of file uploads by file_id
      file_upload_map = file_uploads.each_with_object({}) do |upload, hash|
        hash[upload.file_id] = upload
      end

      # Fetch the content for each file that exists in both S3 and MongoDB
      files = objects.each_with_object([]) do |object, result|
        if file_upload_map.key?(object.key)  # Check if the file_id exists in MongoDB
          file_content = S3_CLIENT.get_object(bucket: BUCKET_NAME, key: object.key).body.read

          result <<
            FileUploadDTO.new(
              object.key,
              Base64.encode64(file_content),
              file_upload_map[object.key].size,
              file_upload_map[object.key].created_at.iso8601
            ).to_h
        end
      end

      Rails.logger.info("#{LOG_PREFIX} Successfully fetched #{files.size} files.")
      files

    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error("#{LOG_PREFIX} An error occurred while fetching files: #{e.message}")
      raise e  # Reraise the error for further handling
    end
  end

  def self.get_file(id)
    Rails.logger.info("#{LOG_PREFIX} Fetching file with ID: #{id}")

    response = S3_CLIENT.get_object(bucket: BUCKET_NAME, key: id)
    file_data = response.body.read

    file_upload = find_by_file_id(id)

    FileUploadDTO.new(
      id,
      Base64.encode64(file_data),
      file_data.bytesize,
      file_upload.created_at.iso8601
    ).to_h
  rescue Aws::S3::Errors::NoSuchKey
    Rails.logger.error("#{LOG_PREFIX} File with ID: #{id} not found.")
    raise ActiveRecord::RecordNotFound, "File not found."
  end

  def self.delete_file(id)
    Rails.logger.info("#{LOG_PREFIX} Deleting file with ID: #{id}")
    S3_CLIENT.delete_object(bucket: BUCKET_NAME, key: id)

    file_upload = find_by_file_id(id)

    if file_upload
      file_upload.destroy
    else
      Rails.logger.warn("#{LOG_PREFIX} No file found with ID: #{file_id}. Deletion skipped.")
      raise ActiveRecord::RecordNotFound, "File with ID: #{file_id} not found."
    end

    Rails.logger.info("#{LOG_PREFIX} File with ID: #{id} deleted successfully.")
  rescue Aws::S3::Errors::NoSuchKey
    Rails.logger.error("#{LOG_PREFIX} Failed to delete file with ID: #{id}. File not found.")
    raise ActiveRecord::RecordNotFound, "File not found."
  end

  private

  def self.determine_content_type(original_filename)
    extension = File.extname(original_filename).delete(".")
    mime_type = MIME::Types[extension].first&.content_type || "application/octet-stream"
    Rails.logger.debug("#{LOG_PREFIX} Determined content type for #{original_filename}: #{mime_type}")
    mime_type
  end


  def self.generate_description(original_filename)
    description = "Uploaded file: #{original_filename}"
    Rails.logger.debug("#{LOG_PREFIX} Generated description for #{original_filename}: #{description}")
    description
  end

  def self.generate_tags(original_filename)
    base_name = File.basename(original_filename, ".*")
    tags = base_name.split(/[\s._-]+/)
    tags = tags.map(&:downcase).uniq
    Rails.logger.debug("#{LOG_PREFIX} Generated tags for #{original_filename}: #{tags.join(", ")}")
    tags
  end

  def self.find_by_file_id(file_id)
    FileUpload.where(file_id: file_id).first
  end

end

