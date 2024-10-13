require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String
  field :password_digest, type: String
  field :salt, type: String

  index({ username: 1 }, { unique: true })

  validates :username, presence: true, uniqueness: true

  # Custom password setter to store password salt
  def password=(new_password)
    self.salt = BCrypt::Engine.generate_salt
    self.password_digest = BCrypt::Engine.hash_secret(new_password, salt)
  end

  # Method to authenticate user password
  def authenticate(password)
    BCrypt::Engine.hash_secret(password, salt) == password_digest
  end
end
