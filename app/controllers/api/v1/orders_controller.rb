class Api::V1::OrdersController < ApplicationController
    def index
        orders = Order.all
        render json: orders, status: 200
    end

    def create
        order = Order.new(
            user: order_params[:user],
            status: order_params[:status],
            price: self.order_price
        )
        if order.save
            render json: order, status: 200
        else
            render json: { error: "Error creating order." }
        end
    end
    
    def order_price
        price = 0
        config_parts.each do |part_id|
            price += get_part_price(part_id, config_parts)
        end
        return price
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
        params.require(:config).permit([
            :user,
            :status
        ])
    end
end
