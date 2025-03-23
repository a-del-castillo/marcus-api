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
      incompatible_with: part_params[:incompatible_with],
      extra_props: part_params[:extra_props]
    )
    if part.save
      render json: part, status: 200
    else
      render json: {error: "Error creating part."}
    end
  end

  def show
    part = Part.find_by(id: params[:id])
    if part
      render json: part, status: 200
    else
      render json: {error: "Part not found."}
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
