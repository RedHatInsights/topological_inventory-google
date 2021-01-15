require "topological_inventory/google/logging"
require "topological_inventory/google/connection"
require "topological_inventory/providers/common/operations/source"

module TopologicalInventory
  module Google
    module Operations
      class Source < TopologicalInventory::Providers::Common::Operations::Source
        include Logging

        private

        # endpoint connection check
        def connection_check
          project_id = authentication.username
          service_account_json = authentication.password
          TopologicalInventory::Google::Connection.raw_connect(project_id, service_account_json, {:service => 'compute'})

          [STATUS_AVAILABLE, nil]
        rescue => e
          logger.availability_check("Failed to connect to Source id:#{source_id} - #{e.message}", :error)
          [STATUS_UNAVAILABLE, e.message]
        end
      end
    end
  end
end
