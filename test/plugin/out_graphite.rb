require 'test_helper'
require 'fluent/plugin/out_graphite'
require 'timecop'

class GraphiteOutputTest < Test::Unit::TestCase
  def setup
    super
    Fluent::Test.setup
    @now = Time.now
    Timecop.freeze(@now)
  end

  def treedown
    Timecop.return
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
    time = Time.at(@now.to_i).utc
    time_priv_tick = Time.at(@now.to_i - 1).utc
    d.emit({ :key => 'c1', :count => 1 }, time)
    d.emit({ :key => 'c1', :count => 1 }, time)
    d.emit({ :key => 'c1', :count => 1 }, time_priv_tick)
    d.emit({ :key => 'c2', :count => 1 }, time)
    d.emit({ :key => 'c2', :count => 2 }, time)
    d.emit({ :key => 'c3', :count => 1 }, time_priv_tick)

    d.emit({ :key => 'c1', :gauge => 10 }, time)
    d.emit({ :key => 'c1', :gauge => 20 }, time_priv_tick)

    mock(d.instance.graphite).post <<MESSAGE
stats.counts.c1 3 #{@now.to_i}
stats.counts.c2 3 #{@now.to_i}
stats.counts.c3 1 #{@now.to_i}
stats.gauges.c1 20 #{@now.to_i}
MESSAGE
    d.run
  end
end
