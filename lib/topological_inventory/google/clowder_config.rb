require 'app-common-ruby'
require 'singleton'

module TopologicalInventory
  module Google
    class ClowderConfig
      include Singleton

      def self.instance
        @instance ||= {}.tap do |options|
          if ENV["CLOWDER_ENABLED"].present?
            config                        = ::LoadedConfig # TODO not an ideal name
            options["metricsPort"]        = config.metricsPort
            options["metricsPath"]        = config.metricsPath
            broker = config.kafka.brokers.first
            options["kafkaHost"] = broker.hostname
            options["kafkaPort"] = broker.port

            options["kafkaTopics"]        = {}.tap do |topics|
              config.kafka.topics.each do |topic|
                topics[topic.requestedName.to_s] = topic.name.to_s
              end
            end
            options["logGroup"]           = config.logging.cloudwatch.logGroup
            options["awsRegion"]          = config.logging.cloudwatch.region
            options["awsAccessKeyId"]     = config.logging.cloudwatch.accessKeyId
            options["awsSecretAccessKey"] = config.logging.cloudwatch.secretAccessKey

          else
            options["metricsPort"]        = (ENV['METRICS_PORT'] || 9394).to_i
            options["kafkaBrokers"]       = ["#{ENV['QUEUE_HOST']}:#{ENV['QUEUE_PORT']}"]
            options["logGroup"]           = 'platform-dev'
            options["awsRegion"]          = 'us-east-1'
            options["awsAccessKeyId"]     = ENV['CW_AWS_ACCESS_KEY_ID']
            options["awsSecretAccessKey"] = ENV['CW_AWS_SECRET_ACCESS_KEY']
            options["kafkaHost"]         = ENV['QUEUE_HOST'] || 'localhost'
            options["kafkaPort"]         = (ENV['QUEUE_PORT'] || '9092').to_i
          end
        end
      end

      def self.fill_args_operations(args)
        args[:metrics_port] = instance['metricsPort']
        args[:queue_host] = instance['kafkaHost']
        args[:queue_port] = instance['kafkaPort']
        args
      end

      def self.kafka_topic(name)
        instance["kafkaTopics"][name] || name
      end
    end
  end
end

# ManageIQ Message Client depends on these variables
ENV["QUEUE_HOST"] = TopologicalInventory::Google::ClowderConfig.instance["kafkaHost"]
ENV["QUEUE_PORT"] = TopologicalInventory::Google::ClowderConfig.instance["kafkaPort"].to_s

# ManageIQ Logger depends on these variables
ENV['CW_AWS_ACCESS_KEY_ID']     = TopologicalInventory::Google::ClowderConfig.instance["awsAccessKeyId"]
ENV['CW_AWS_SECRET_ACCESS_KEY'] = TopologicalInventory::Google::ClowderConfig.instance["awsSecretAccessKey"]
