
module Fluent
  class GraphiteOutput < BufferedOutput
    Fluent::Plugin.register_output('graphite', self)

    config_param :flush_interval, :time, :default => 10
    config_param :host, :string, :default => 'localhost'
    config_param :port, :string, :default => '2003'
    config_param :key_prefix, :string, :default => 'stats'

    attr_reader :graphite

    def initialize
      super
    end

    def configure(conf)
      super
      @graphite = Graphite.new(host, port)
    end

    def start
      super
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      record.to_msgpack
    end

    def write(chunk)
      timestamp = Time.now.to_i

      counts = Hash.new {|h,k| h[k] = 0 }
      timers = Hash.new {|h,k| h[k] = [] }
      gauges = {}

      chunk.msgpack_each {|record|
        if key = record['key']
          next if rand() > record['sampling'] if record['sampling'].kind_of?(Float)

          if record['count']
            counts[key] += record['count'].to_i
          elsif record['gauge']
            gauges[key] = record['gauge'].to_i
          elsif record['timer']
            timers[key] << record['timer'].to_i
          end
        end
      }

      post_data(counts, timers, gauges, timestamp)
    end

    def post_data(counts, timers, gauges, timestamp)
      message = []

      counts.each {|key, value|
        message << "#{key_prefix}.counts.#{key} #{value} #{timestamp}"
      }

      gauges.each {|key, value|
        message << "#{key_prefix}.gauges.#{key} #{value} #{timestamp}"
      }

      # TODO: implements
      timers

      @graphite.post(message.join("\n") + "\n")
    end

    class Graphite
      attr_reader :host, :port
      def initialize(host, port)
        @host = host
        @port = port
      end

      def post(message)
        TCPSocket.open(host, port) {|socket|
          socket.write(message)
        }
      end
    end
  end
end
