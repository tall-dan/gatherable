module Gatherable
  class ApplicationController < ::ActionController::Base
    before_action :authenticate, only: [:create]

    def show
      render :json => model_class.find_by!(params.slice(model_id, global_identifier)), :status => :found
    rescue ActiveRecord::RecordNotFound => e
      render :json => { :errors => e.message}, :status => :not_found
    end

    def create
      render :json => model_class.create!(model_params), :status => :created
    rescue StandardError => e
      render :json => { :errors => e.message}, :status => :unprocessable_entity
    end

    private

    def authenticate
      return unless Gatherable.config.auth_method == :session
      head :unauthorized unless params[global_identifier] == session[global_identifier]
    end

    def model_class
      Object.const_get(model_name)
    end

    def model_name
      self.class.to_s.chomp('Controller').singularize
    end

    def model_id
      "#{unmodularized_model_name}_id"
    end

    def unmodularized_model_name
      model_name.split('::').last.downcase
    end

    def model_params
      params.require(unmodularized_model_name).permit(
        *model_class.column_names
      ).merge(global_identifier => params[global_identifier])
    end

    def global_identifier
      Gatherable.config.global_identifier
    end
  end
end
