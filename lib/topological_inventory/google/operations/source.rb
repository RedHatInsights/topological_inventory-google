require "topological_inventory/google/logging"
require "topological_inventory/providers/common/operations/source"

module TopologicalInventory
  module Google
    module Operations
      class Source < TopologicalInventory::Providers::Common::Operations::Source
        include Logging

        private

        def connection_check
          raise "Endpoint's availability check is not available"
        end
      end
    end
  end
end
