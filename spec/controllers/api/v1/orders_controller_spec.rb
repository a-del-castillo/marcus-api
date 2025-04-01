require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  # Configuración común para las pruebas que requieren autenticación
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: 'admin') }
  let(:token) { JWT.encode({user_id: user.id}, Rails.application.credentials.secret_jwt_key, 'HS256') }
  let(:admin_token) { JWT.encode({user_id: admin.id}, Rails.application.credentials.secret_jwt_key, 'HS256') }

  describe 'GET #index' do
    context 'when user is authenticated' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
        create_list(:order, 3, user: user)
      end

      it 'returns all orders for the current user' do
        get :index
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'when user is admin' do
      before do
        request.headers['Authorization'] = "Bearer #{admin_token}"
        create_list(:order, 5)
      end

      it 'returns all orders in the system' do
        get :index
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body).size).to eq(5)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get :index
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    let(:order) { create(:order, user: user) }
    
    context 'when user is authenticated and owns the order' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'returns the requested order' do
        get :show, params: { id: order.id }
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['id']).to eq(order.id)
      end
    end

    context 'when user is admin' do
      before do
        request.headers['Authorization'] = "Bearer #{admin_token}"
      end

      it 'returns any requested order' do
        other_user_order = create(:order)
        
        get :show, params: { id: other_user_order.id }
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['id']).to eq(other_user_order.id)
      end
    end

    context 'when order does not exist' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'returns not found status' do
        get :show, params: { id: 999 }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:part) { create(:part) }
    let(:part_2) { create(:part) }
    let(:valid_attributes) do
      {
        order: {
          parts_ids: [create(:part).id, create(:part).id],
          status: "in Cart"
        }
      }
    end

    context 'when user is authenticated' do
      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'creates a new order' do
        expect {
          post :create, params: valid_attributes
        }.to change(Order, :count).by(1)
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['id']).to eq(Order.last.id)
      end

      it 'creates order items for each part' do
        expect {
          post :create, params: valid_attributes
        }.to change(OrderArticle, :count).by(2)
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
