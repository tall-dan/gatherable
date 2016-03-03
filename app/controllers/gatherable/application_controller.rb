module Gatherable
  class ApplicationController < ::ActionController::Base
    before_action :set_gatherable_id
    before_action :authenticate

    def index
      render :json => model_class.where(global_id => global_id_val), :status => :found
    end

    def show
      render :json => model_class.find_by!(global_id => global_id_val, model_id => params[model_id]), :status => :found
    rescue ActiveRecord::RecordNotFound => e
      render :json => { :errors => e.message}, :status => :not_found
    end

    def create
      if data_table.new_record_strategy == :update
        model = model_class.find_or_initialize_by(global_id => global_id_val)
        model.update_attributes(model_params)
        render :json => model, :status => :ok
      else
        render :json => model_class.create!(model_params), :status => :created
      end
    rescue StandardError => e
      render :json => { :errors => e.message}, :status => :unprocessable_entity
    end

    def update
      model_instance.update_attributes!(model_params)
      render :json => model_instance, :status => :ok
    rescue ActiveRecord::RecordNotFound => e
      render :json => { :errors => e.message}, :status => :not_found
    rescue StandardError => e
      render :json => { :errors => e.message}, :status => :unprocessable_entity
    end

    def destroy
      model_instance.delete
      head :no_content
    rescue ActiveRecord::RecordNotFound => e
      render :json => { :errors => e.message}, :status => :not_found
    end

    private

    def authenticate
      return unless Gatherable.config.auth_method == :session
      return unless requires_global_id_param?
      head :unauthorized unless params[global_id] == session[global_id]
    end

    def model_instance
      model_class.find_by!(params.slice(model_id, global_id_val))
    end

    def model_class
      Gatherable.const_get(unmodularized_model_name)
    end

    def model_name
      self.class.to_s.chomp('Controller').singularize
    end

    def model_id
      "#{model_name_as_var}_id"
    end

    def unmodularized_model_name
      model_name.split('::').last
    end

    def model_name_as_var
      unmodularized_model_name.underscore
    end

    def model_params
      params.require(model_name_as_var).permit(
        *model_class.column_names - [global_id]
      ).merge(global_id => global_id_val)
    end

    def global_id
      Gatherable.config.global_identifier
    end

    def data_table
      DataTable.find_by_name(model_name_as_var)
    end

    def set_gatherable_id
      session[global_id] ||= SecureRandom.urlsafe_base64
    end

    def global_id_val
      requires_global_id_param? ? params[global_id] : session[global_id]
    end

    def requires_global_id_param?
      Gatherable.config.prefixed_resources.include? data_table.name
    end
  end
end
