class Api::V1::ConfigsController < ApplicationController
    def index
        configs = Config.all
        render json: configs, status: 200
    end

    def create
        config = Config.new(
            name: config_params[:name],
            parts: config_params[:parts],
            user: config_params[:parts],
            price: config_price
        )
        if config.save
            render json: config, status: 200
        else
            render json: { error: "Error creating configuration." }
        end
    end

    def config_price_req
        # config_parts = params[:parts]
        config_parts =  JSON.parse params[:parts]
        render json: { price: config_price(config_parts) }, status: 200
    end
    
    def config_price(config_parts)
        price = 0
        config_parts.each do |part_id|
            price += get_part_price(part_id, config_parts)
        end
        return price
    end

    def get_part_price(part_id, parts_list)
        part = Part.find_by(id: part_id)
        if part
            part.pricemodifiers.each do |pricemod|
                if parts_list.include?(pricemod.variator_part.id)
                    return pricemod.price
                end
            end
            return part.price
        end

        return 0
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
