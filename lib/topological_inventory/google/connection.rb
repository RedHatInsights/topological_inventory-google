require 'topological_inventory/google/logging'
require 'fog/google'

module TopologicalInventory
  module Google
    class Connection
      class << self
        include Logging

        def raw_connect(google_project, google_json_key, options, proxy_uri = nil, validate = false)
          # require "google/apis"
          # ::Google::Apis.logger = logger

          config = {
            :provider               => "Google",
            :google_project         => google_project,
            :google_json_key_string => google_json_key,
            :app_name               => 'c.rh.c',
            :app_version            => '1.0.0',
            :google_client_options  => {:proxy_url => proxy_uri},
          }

          begin
            case options[:service]
              # specify Compute as the default
            when 'compute', nil
              connection = ::Fog::Compute.new(config)
            when 'pubsub'
              connection = ::Fog::Google::Pubsub.new(config.except(:provider))
            when 'monitoring'
              connection = ::Fog::Google::Monitoring.new(config.except(:provider))
            else
              raise ArgumentError, "Unknown service: #{options[:service]}"
            end
            # Not all errors will cause Fog to raise an exception,
            # for example an error in the google_project id will
            # succeed to connect but the first API call will raise
            # an exception, so make a simple call to the API to
            # confirm everything is working
            connection.regions.all if validate
          rescue => err
            raise TopologicalInventory::Google::InvalidCredentialsError, err.message
          end

          connection
        end
      end
    end
  end
end
