require './app/helpers/pricing_helper'

class Api::V1::ConfigsController < ApplicationController
    include PricingHelper

    def index
        configs = Config.all
        render json: configs, status: 200
    end

    def create
        config = Config.new(
            name: config_params[:name],
            parts: config_params[:parts],
            user: config_params[:parts],
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
            render json: { error: "Configuration not found." }
        end
    end

    private
    def config_params
        params.require(:config).permit([
            :name,
            :parts
        ])
    end
end
