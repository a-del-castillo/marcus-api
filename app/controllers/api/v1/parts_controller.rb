class Api::V1::PartsController < ApplicationController
  def index
    parts = Part.all
    render json: parts, status: 200
  end

  def create
    part = Part.new(
      name: part_params[:name],
      category: part_params[:category],
      color: part_params[:color],
      price: part_params[:price],
      available: part_params[:available],
      extra_props: part_params[:extra_props]
    )
    if part.save
      part_params[:incompatible_with].each do |incompatible_part|
        Incompatibility.new(part_1: part.id, part_2:incompatible_part)
      end
      render json: part, status: 200
    else
      render json: {error: "Error creating part."}
    end
  end

  def show
    part = Part.find_by(id: params[:id])
    if part
      incompatibilities = part.incompatibilities
  
      render json: {
        part: part,
        incompatibilities: incompatibilities
      }, status: 200
    else
      render json: { error: "Part not found." }, status: 404
    end
  end

  def available_parts
    part_ids = JSON.parse params[:ids]

    incompatible_part_ids =Incompatibility.where(part_1: part_ids).pluck(:part_2) | Incompatibility.where(part_2: part_ids).pluck(:part_1)

    available_parts = Part.where.not(id: incompatible_part_ids)
    
    if available_parts.any?
      render json: available_parts, status: 200
    else
      render json: { error: "No parts available." }, status: 404
    end
  end  

  private 
    def part_params
      params.require(:part).permit([
        :name,
        :category,
        :color,
        :price,
        :available,
        :incompatible_with,
        :extra_props
      ])
    end
end
