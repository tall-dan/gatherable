require "gatherable/engine"
require "gatherable/configuration"

module Gatherable
  class << self
    def configure
      return unless configuration.empty?
      yield configuration
      create_models
      create_controllers
      create_routes
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias :config :configuration

    private

    def create_models
      config.data_points.map(&:classify)
    end

    def create_controllers
      config.data_points.map(&:controllerify)
    end

    def create_routes
      global_identifier = config.global_identifier
      Gatherable::Engine.routes.draw do #would this wipe away whatever's in config/routes.rb?
        Gatherable.config.data_points.map{ |dp| dp.name.to_s.pluralize }.each do |data_point|
          scope :path => "/:#{global_identifier}" do
            resources data_point.to_sym, :only => [:show, :create], :param => "#{data_point.singularize}_id"
          end
        end
      end
    end
  end
end
