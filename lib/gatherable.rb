require "gatherable/engine"
require "gatherable/configuration"
require 'pry'

module Gatherable
  class << self
    def configure
      yield configuration
      create_routes
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias :config :configuration

    private

    def create_controllers

    end

    def create_routes
      #      global_identifier = config.global_identifier
      Gatherable::Enginer.routes.draw do #would this wipe away whatever's in config/routes.rb?
        configuration.data_points.map(&:name).each do |data_point|
          get "/:global_identifier/#{data_point}/:id", :to => "#{data_point}#show"
          post "/:global_identifier/#{data_point}", :to => "#{data_point}#create"
        end
      end
    end
  end
end
