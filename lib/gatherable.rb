require "gatherable/engine"
require "gatherable/configuration"

module Gatherable
  class << self
    def configure
      return unless configuration.empty?
      yield configuration
      create_models
      create_controllers
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
  end
end
