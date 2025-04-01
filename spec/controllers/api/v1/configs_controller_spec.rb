require 'rails_helper'

RSpec.describe Api::V1::ConfigsController, type: :controller do
  
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: 'admin') }
  let(:token) { JWT.encode({user_id: user.id}, Rails.application.credentials.secret_jwt_key, 'HS256') }
  let(:admin_token) { JWT.encode({user_id: admin.id}, Rails.application.credentials.secret_jwt_key, 'HS256') }

  describe 'GET #index' do
    before do
      create_list(:config, 3)
    end

    it 'returns all configurations' do
      get :index
      
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'GET #show' do
    let(:config) { create(:config) }
    
    it 'returns the requested configuration' do
      get :show, params: { id: config.id }
      
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['id']).to eq(config.id)
    end

    it 'returns not found status when configuration does not exist' do
      get :show, params: { id: 999 }
      
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        config: {
          name: "Test Configuration",
          parts: [create(:part).id, create(:part).id]
        }
      }
    end

    context 'when user is authenticated' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'creates a new configuration' do
        expect {
          post :create, params: valid_attributes
        }.to change(Config, :count).by(1)
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['id']).to eq(Config.last.id)
      end

      it 'associates parts with the configuration' do
        post :create, params: valid_attributes
        
        config = Config.last
        expect(config.parts.count).to eq(2)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        post :create, params: valid_attributes
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
