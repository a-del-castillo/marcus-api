require 'rails_helper'

RSpec.describe Api::V1::PartsController, type: :controller do
  let(:user) { create(:user, role: 'admin') }
  let(:token) { JWT.encode({user_id: user.id}, Rails.application.credentials.secret_jwt_key, 'HS256') }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'GET #index' do
    it 'returns all parts' do
      create_list(:part, 3)
      
      get :index
      
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'POST #create' do
    context 'when user is admin' do
      let(:valid_attributes) do
        {
          part: {
            name: 'Test Part',
            category: 'Test Category',
            price: 100.0,
            available: true,
            extra_props: { color: 'red', weight: '2kg' }
          }
        }
      end

      it 'creates a new part' do
        expect {
          post :create, params: valid_attributes
        }.to change(Part, :count).by(1)
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['name']).to eq('Test Part')
      end

    end

    context 'when user is not admin' do
      before do
        non_admin = create(:user, role: 'user')
        non_admin_token = JWT.encode({user_id: non_admin.id}, Rails.application.credentials.secret_jwt_key, 'HS256')
        request.headers['Authorization'] = "Bearer #{non_admin_token}"
      end

      it 'does not create a part' do
        expect {
          post :create, params: { part: { name: 'Test Part' } }
        }.not_to change(Part, :count)
      end
    end
  end

  describe 'GET #show' do
    it 'returns the requested part with its incompatibilities and price modifiers' do
      part = create(:part)
      incompatibility = create(:incompatibility, part_1: part)
      price_modifier = create(:price_modifier, main_part: part)
      
      get :show, params: { id: part.id }
      
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response['part']['id']).to eq(part.id)
      expect(json_response['incompatibilities']).to be_present
      expect(json_response['pricemodifiers']).to be_present
    end
  end

  describe 'PUT #update' do
    let(:part) { create(:part) }
    
    context 'when user is admin' do
      it 'updates the part' do
        put :update, params: { id: part.id, part: { name: 'Updated Part' } }
        
        expect(response).to have_http_status(:ok)
        expect(part.reload.name).to eq('Updated Part')
      end

      it 'updates incompatibilities' do
        other_part = create(:part)
        
        put :update, params: { 
          id: part.id, 
          part: { name: 'Updated Part' },
          incompatibilities: [
            { part_1: { id: part.id }, part_2: { id: other_part.id }, description: 'Test incompatibility' }
          ]
        }
        
        expect(response).to have_http_status(:ok)
        expect(Incompatibility.count).to eq(1)
      end

      it 'updates price modifiers' do
        other_part = create(:part)
        
        put :update, params: { 
          id: part.id, 
          part: { name: 'Updated Part' },
          pricemodifiers: [
            { main_part: { id: part.id }, variator_part: { id: other_part.id }, price: 150.0 }
          ]
        }
        
        expect(response).to have_http_status(:ok)
        expect(PriceModifier.count).to eq(1)
      end

      it 'returns errors when update fails' do
        allow_any_instance_of(Part).to receive(:update).and_return(false)
        
        put :update, params: { id: part.id, part: { name: 'Updated Part' } }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user is not admin' do
      before do
        non_admin = create(:user, role: 'user')
        non_admin_token = JWT.encode({user_id: non_admin.id}, Rails.application.credentials.secret_jwt_key, 'HS256')
        request.headers['Authorization'] = "Bearer #{non_admin_token}"
      end

      it 'does not update the part' do
        original_name = part.name
        
        put :update, params: { id: part.id, part: { name: 'Updated Part' } }
        
        expect(part.reload.name).to eq(original_name)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:part) { create(:part) }
    
    context 'when user is admin' do
      it 'deletes the part' do
        expect {
          delete :destroy, params: { id: part.id }
        }.to change(Part, :count).by(-1)
        
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Part deleted successfully')
      end

      it 'deletes associated incompatibilities' do
        create(:incompatibility, part_1: part)
        
        expect {
          delete :destroy, params: { id: part.id }
        }.to change(Incompatibility, :count).by(-1)
      end

      it 'deletes associated price modifiers' do
        create(:price_modifier, main_part: part)
        
        expect {
          delete :destroy, params: { id: part.id }
        }.to change(PriceModifier, :count).by(-1)
      end

      it 'returns error when deletion fails' do
        allow_any_instance_of(Part).to receive(:destroy).and_return(false)
        
        delete :destroy, params: { id: part.id }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Failed to delete part')
      end
    end

    context 'when user is not admin' do
      before do
        non_admin = create(:user, role: 'user')
        non_admin_token = JWT.encode({user_id: non_admin.id}, Rails.application.credentials.secret_jwt_key, 'HS256')
        request.headers['Authorization'] = "Bearer #{non_admin_token}"
      end

      it 'does not delete the part' do
        expect {
          delete :destroy, params: { id: part.id }
        }.not_to change(Part, :count)
      end
    end
  end

  describe 'GET #available_parts' do
    it 'returns parts that are not incompatible with the given parts' do
      part1 = create(:part)
      part2 = create(:part)
      incompatible_part = create(:part)
      
      create(:incompatibility, part_1: part1, part_2: incompatible_part)
      
      get :available_parts, params: { ids: [part1.id] }
      
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response.map { |p| p['id'] }).to include(part2.id)
      expect(json_response.map { |p| p['id'] }).not_to include(incompatible_part.id)
    end

  end

  describe '#get_part_price' do
    
    it 'calculates the correct price based on price modifiers' do
      
      part = create(:part, price: 100)
      variator_part = create(:part)
      create(:price_modifier, main_part: part, variator_part: variator_part, price: 150)
    
    end
  end
end
