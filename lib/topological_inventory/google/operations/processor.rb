require "topological_inventory/google/logging"
require "topological_inventory/google/operations/source"
require "topological_inventory/providers/common/operations/processor"

module TopologicalInventory
  module Google
    module Operations
      class Processor < TopologicalInventory::Providers::Common::Operations::Processor
        include Logging

        def operation_class
          "#{Operations}::#{model}".safe_constantize
        end
      end
    end
  end
end
