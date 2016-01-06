require "gatherable/engine"
require "gatherable/configuration"
require 'pry'

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
      config.data_tables.map(&:classify)
    end

    def create_controllers
      config.data_tables.map(&:controllerify)
    end

    def create_routes
      global_identifier = config.global_identifier
      Gatherable::Engine.routes.draw do #would this wipe away whatever's in config/routes.rb?
        Gatherable.config.data_tables.map{ |dp| dp.name.to_s.pluralize }.each do |data_table|
          scope :path => "/:#{global_identifier}" do
            resources data_table.to_sym, :only => [:show, :create], :param => "#{data_table.singularize}_id"
          end
        end
      end
    end
  end
end
