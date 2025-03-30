class Api::V1::PartsController < ApplicationController
    before_action :set_part, only: [:show, :update, :destroy]
    
    def index
        parts = Part.all
        render json: parts, status: 200
    end

    def create
        if is_admin
            part = Part.new(
                name: part_params[:name],
                category: part_params[:category],
                #color: part_params[:color],
                price: part_params[:price],
                available: part_params[:available],
                extra_props: part_params[:extra_props]
            )
            if part.save
                if params[:incompatibilities].present?
                    part_params[:incompatibilities].each do |incompatible_part|
                        Incompatibility.new(part_1: part.id, part_2: incompatible_part.id)
                    end
                end
                render json: part, status: 200
            else
                render json: { error: "Error creating part." }
            end
        end
    end

    def update
        if is_admin
            if @part.update(part_params)
                Incompatibility.where(part_1: @part.id).or(Incompatibility.where(part_2: @part.id)).delete_all
                if params[:incompatibilities].present?
                    params[:incompatibilities].each do |incompatibility|
                        part_1 = Part.find(incompatibility[:part_1][:id])
                        part_2 = Part.find(incompatibility[:part_2][:id])
                        Incompatibility.create(part_1: part_1, part_2: part_2, description: incompatibility[:description])
                    end
                end

                PriceModifier.where(main_part: @part.id).delete_all
                if params[:pricemodifiers].present?
                    params[:pricemodifiers].each do |pricemodifier|
                        part_1 = Part.find(pricemodifier[:main_part][:id])
                        part_2 = Part.find(pricemodifier[:variator_part][:id])
                        PriceModifier.create(main_part: part_1, variator_part: part_2, price: pricemodifier[:price])
                    end
                end
                render json: @part, status: :ok
            else
                render json: @part.errors, status: :unprocessable_entity
            end
        end
    end

    def destroy
        if is_admin
            if @part.destroy
                Incompatibility.where(part_1: @part.id).or(Incompatibility.where(part_2: @part.id)).delete_all
                PriceModifier.where(main_part: @part.id).delete_all
                render json: { message: 'Part deleted successfully' }, status: :ok
            else
                render json: { error: 'Failed to delete part' }, status: :unprocessable_entity
            end
        end
    end

    def show
        part = Part.find_by(id: params[:id])
        if part
            incompatibilities = part.incompatibilities
            pricemodifiers = part.pricemodifiers

            render json: { part: part, incompatibilities: incompatibilities, pricemodifiers: pricemodifiers }, status: 200
        else
            render json: { error: "Part not found." }, status: 404
        end
    end

    def available_parts
        part_ids = params[:ids]

        incompatible_part_ids =Incompatibility.where(part_1: part_ids).pluck(:part_2) | Incompatibility.where(part_2: part_ids).pluck(:part_1)

        available_parts = Part.where.not(id: incompatible_part_ids)

        if available_parts.any?
            render json: available_parts, status: 200
        else
            render json: { error: "No parts available." }, status: 404
        end
    end

    def get_part_price
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

    private
    
    def secret_key
        Rails.application.credentials.secret_jwt_key
    end

    def is_admin
        token = request.headers["Authorization"].split(" ")[1]
        decoded_hash = (JWT.decode(token, secret_key, true, algorithm: "HS256"))
        if !decoded_hash.empty?
            user = User.find_by(id: decoded_hash[0]["user_id"])
            if user.role === 'admin'
                return true
            end
        end
        return false
    end

    def set_part
        @part = Part.find(params[:id])
    end

    def part_params
        params.require(:part).permit(
            :id,  # Permitir id si deseas usarlo (en el caso de que estés actualizando un registro existente)
            :name,
            :category,
            :color,
            :price,
            :available,
            :created_at, 
            :updated_at,
            extra_props: {},
            incompatibilities: [
                :description,
                { part_1: [:id, :name, :category, :price, :available, :extra_props] },
                { part_2: [:id, :name, :category, :price, :available, :extra_props] }
            ],
            pricemodifiers: [
                { main_part: [:id, :name, :category] },
                { variator_part: [:id, :name, :category] },
                :price
            ]
        )
    end
end
