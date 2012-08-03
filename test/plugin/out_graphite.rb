require 'test_helper'
require 'fluent/plugin/out_graphite'

class GraphiteOutputTest < Test::Unit::TestCase
  def setup
    super
    Fluent::Test.setup
  end

  CONFIG = %[
    type graphite
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::GraphiteOutput) {
    }.configure(conf)
  end

  def test_write
    d = create_driver
    time = Time.at(Time.now.to_i).utc
    d.emit({}, time)
    d.run
  end
end
