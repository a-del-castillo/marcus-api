require './app/helpers/pricing_helper'
class Api::V1::OrdersController < ApplicationController
    include PricingHelper

    def index
        orders = Order.all
        render json: orders, status: 200
    end

    def create
        create_params = params.require(:order).permit(:status, parts_attributes: [:id])
        create_params[:user] = current_user[:id]
        @order = Order.new(create_params)
    
        if @order.save
            order_price = 0
            if params[:order][:parts_ids].present?
                params[:order][:parts_ids].each do |part_id|
                    OrderArticle.create(order_id: @order.id, part_id: part_id)
                    order_price += Part.find(part_id).price
                end
                
            end

            if params[:order][:configs].present?
                params[:order][:configs].each do |config|
                    config_price = calculate_config_price(config[:parts])
                    new_config = Config.new(
                        name: config[:name],
                        parts: config[:parts],
                        user: current_user[:id],
                        price: config_price.to_f.round(2)
                    )
                    new_config.save
                    order_price += config_price
                    OrderArticle.create(order_id: @order.id, config_id: new_config[:id])
                end
            end
    
            @order.price = order_price
            @order.save
            
            render json: @order, status: 200
        else
            render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def update
        update_params = params.require(:order).permit(:status, parts_attributes: [:id, :name, :category, :price, :available, :quantity], configs_attributes: [:id, :name, :price, :user_id, parts: []])

        @order = Order.find_by(user: current_user.id, status: 'in cart')
        if @order.update(update_params)
            #TODO delete configs from db
            OrderArticle.where(order_id: @order.id).delete_all
            order_price = 0
            if params[:order][:parts_ids].present?
                params[:order][:parts_ids].each do |part_id|
                    OrderArticle.create(order_id: @order.id, part_id: part_id)
                    order_price += Part.find(part_id).price
                end
                
            end

            if params[:order][:configs].present?
                params[:order][:configs].each do |config|
                    config_price = calculate_config_price(config[:parts])
                    new_config = Config.new(
                        name: config[:name],
                        parts: config[:parts],
                        user: current_user[:id],
                        price: config_price.to_f.round(2)
                    )
                    new_config.save
                    order_price += config_price
                    OrderArticle.create(order_id: @order.id, config_id: new_config[:id])
                end
            end
    
            @order.price = order_price
            @order.save

            render json: @order, status: :ok
        else
            render json: @order.errors, status: :unprocessable_entity
        end
    
    end

    def show_current
        order = Order.find_by(user: current_user.id, status: 'in cart')
        if order
            order_parts_with_quantity = order.parts.as_json(order_id: order.id)
            render json: { order: order, parts: order_parts_with_quantity, configs: order.configs }, status: 200
        else
            render json: { error: "No order in cart." }
        end
    end

    def show
        order = Order.find_by(id: params[:id])
        if order
            render json: order, status: 200
        else
            render json: { error: "Order not found." }
        end
    end

    private
    def order_params
        params.require(:order).permit(
          :id,
          :user,
          :status,
          parts_attributes: [:id, :name, :category, :price, :available, :quantity],
          configs_attributes: [:id, :name, :price, :user_id, parts: []]
        )
    end

    def secret_key
        Rails.application.credentials.secret_jwt_key
    end

    def current_user
        token = request.headers["Authorization"].split(" ")[1]
        decoded_hash = (JWT.decode(token, secret_key, true, algorithm: "HS256"))
        if !decoded_hash.empty?
            user = User.find_by(id: decoded_hash[0]["user_id"])
            return user
        end
        return false
    end
end
