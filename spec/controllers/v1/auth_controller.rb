require 'rails_helper'

RSpec.describe V1::AuthController, type: :request do
  let!(:user) { User.create(username: 'testuser', password: 'password') }
  let(:valid_attributes) { { user: { username: 'testuser', password: 'password' } } }
  let(:invalid_attributes) { { user: { username: '', password: '' } } }

  describe 'POST #signup' do
    it 'creates a new user' do
      expect {
        post '/v1/auth/signup', params: valid_attributes, headers: { 'Content-Type': 'application/json' }
      }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'does not create a user with invalid attributes' do
      post '/v1/auth/signup', params: invalid_attributes, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST #login' do
    it 'logs in a user' do
      post '/v1/auth/login', params: { username: 'testuser', password: 'password' }, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(:ok)
      expect(json_response['token']).to be_present
    end

    it 'does not log in with invalid credentials' do
      post '/v1/auth/login', params: { username: 'wronguser', password: 'wrongpassword' }, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['error']).to eq('Invalid username or password')
    end
  end

  describe 'DELETE #destroy' do
    before do
      # Log in to obtain a JWT token
      post '/v1/auth/login', params: { username: 'testuser', password: 'password' }, headers: { 'Content-Type': 'application/json' }
      @token = json_response['token']
    end

    it 'deletes the user' do
      delete '/v1/auth/delete', headers: { 'Authorization': "Bearer #{@token}" }
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('User deleted successfully')
    end

    it 'does not allow access to deleted user' do
      delete '/v1/auth/delete', headers: { 'Authorization': "Bearer #{@token}" }
      expect(response).to have_http_status(:ok)

      post '/v1/auth/login', params: { username: 'testuser', password: 'password' }, headers: { 'Content-Type': 'application/json' }
      expect(response).to have_http_status(:unauthorized)
      expect(json_response['error']).to eq('Invalid username or password')
    end
  end

  after do
    user.destroy # Clean up user after tests
  end
end
