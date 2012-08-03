
module Fluent
  class GraphiteOutput < BufferedOutput
    Fluent::Plugin.register_output('graphite', self)

    include SetTagKeyMixin
    config_set_default :include_tag_key, false

    include SetTimeKeyMixin
    config_set_default :include_time_key, true

    def initialize
      super
    end

    def configure(conf)
      super
    end

    def start
      super
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each {|tag, time, record|
      }
    end
  end
end
