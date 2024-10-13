class FileUploadDTO
  attr_accessor :id, :data, :size, :created_at

  def initialize(id, data, size, created_at)
    @id = id
    @data = data
    @size = size
    @created_at = created_at
  end


  def to_h
    {
      id: @id,
      data: @data,
      size: @size,
      created_at: @created_at
    }.transform_keys { |key| key.to_s.camelcase(:lower) } # Transform keys to camel case
  end
end
