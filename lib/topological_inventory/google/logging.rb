require "topological_inventory/providers/common/logging"

module TopologicalInventory
  module Google
    class << self
      attr_writer :logger
    end

    def self.logger
      @logger ||= TopologicalInventory::Providers::Common::Logger.new
    end

    module Logging
      def logger
        TopologicalInventory::Google.logger
      end
    end
  end
end
