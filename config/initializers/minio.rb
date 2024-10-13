# config/initializers/aws_s3.rb

require 'aws-sdk-s3'

Aws.config.update({
                    region: "us-east-1",       # e.g., 'us-west-2'
                    credentials: Aws::Credentials.new(
                      "minio",     # Your AWS access key
                      "minio123"# Your AWS secret key
                    )
                  })

S3_CLIENT = Aws::S3::Client.new(
  endpoint: "http://localhost:9000", # Your MinIO endpoint, e.g., 'http://localhost:9000'
  force_path_style: true            # Required for MinIO compatibility
)
