class Api::V1::ConfigsController < ApplicationController
  def index
    configs = Config.all
    render json: configs, status: 200
  end

  def create
    config = Config.new(
      name: config_params[:name],
      parts: config_params[:parts]
    )
    if config.save
      render json: config, status: 200
    else
      render json: { error: "Error creating configuration." }
    end
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
