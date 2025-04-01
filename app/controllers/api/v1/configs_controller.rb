require './app/helpers/pricing_helper'

class Api::V1::ConfigsController < ApplicationController
    include PricingHelper
    before_action :authenticate_user, only: [:create]

    def index
        configs = Config.all
        render json: configs, status: 200
    end

    def create
        config = Config.new(
            name: config_params[:name],
            parts: config_params[:parts],
            user: current_user[:id],
            price: calculate_config_price(config_params[:parts])
        )
        
        if config.save
            render json: config, status: 200
        else
            render json: { error: "Error creating configuration." }
        end
    end

    def config_price_req
        config_parts =  JSON.parse params[:parts]
        render json: { price: calculate_config_price(config_parts) }, status: 200
    end
    
    def show
        config = Config.find_by(id: params[:id])
        if config
            render json: config, status: 200
        else
            render json: { error: "Configuration not found." }, status: 404
        end
    end

    private
    def config_params
        params.require(:config).permit([
            :name,
            parts: []
        ])
    end

    def secret_key
        Rails.application.credentials.secret_jwt_key
    end

    def current_user
        return nil unless request.headers['Authorization'].present?

        begin
            token = request.headers["Authorization"].split(" ")[1]
            decoded_hash = JWT.decode(token, secret_key, true, algorithm: "HS256")
            User.find_by(id: decoded_hash[0]["user_id"])
        rescue JWT::DecodeError, NoMethodError
            nil
        end
    end

    def authenticate_user
        unless current_user
            render json: { error: "You need to be logged in to perform this action." }, status: :unauthorized
            return
        end
    end
end
