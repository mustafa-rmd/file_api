require_relative "../../helpers/jwt_helper"

module V1
  class AuthController < ActionController::API
    def signup
      @user = User.new(user_params)
      if @user.save
        token = JwtHelper.encode({ user_id: @user.id.to_s })
        render json: { token: token }, status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def login
      @user = User.where(username: params[:username]).first
      if @user&.authenticate(params[:password])
        token = JwtHelper.encode({ user_id: @user.id.to_s })
        render json: { token: token }, status: :ok
      else
        render json: { error: 'Invalid username or password' }, status: :unauthorized
      end
    end

    def destroy
      @user = User.find_by(id: current_user.id) # Assuming current_user is set in ApplicationController
      if @user&.destroy
        render json: { message: 'User deleted successfully' }, status: :ok
      else
        render json: { error: 'Failed to delete user' }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:username, :password)
    end
  end
end
