class ApplicationController < ActionController::API
  before_action :authenticate_request

  def authenticate_request
    # Extract the Authorization header
    header = request.headers["Authorization"]

    # Check if the token exists
    if header.nil? || !header.start_with?("Bearer ")
      render json: { errors: "Unauthorized" }, status: :unauthorized and return
    end

    # Get the token from the header
    token = header.split(" ").last

    # Decode the token and retrieve user ID
    decoded = JwtHelper.decode(token)
    # Check if decoded is nil or does not contain a user_id
    if decoded.nil? || !decoded.key?("user_id")
      render json: { errors: "Unauthorized" }, status: :unauthorized and return
    end

    # Find the user based on the ID in the decoded token
    @current_user = User.find(BSON::ObjectId(decoded["user_id"]))
    # Check if the user is found, else return unauthorized
    if @current_user.nil?
      render json: { errors: "Unauthorized" }, status: :unauthorized and return
    end

  rescue Mongoid::Errors::DocumentNotFound, JWT::DecodeError
    # Render an unauthorized response if user not found or token is invalid
    render json: { errors: "Unauthorized" }, status: :unauthorized
  end
end
