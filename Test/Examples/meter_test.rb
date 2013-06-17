require 'test/unit'
require_relative '../test_helper'

context :Meter do
  def initialize(clock, start_pos)
    @clock = clock
    @route = Route.new({0 => {1 => 1.25}}, Road_types.new)
    route.update_position start_pos
    @price_per_sec = 0.05
  end

  role :price_per_sec do end

  role :route do
    def price
      route.calculate_price clock.start
    end
  end

  role :clock do
    def price
      clock.duration * price_per_sec
    end
  end

  def current_total(current_position)
    route.update_position current_position
    clock.price + route.price
  end
  def print_route
    route.each_point { |x, y|
      p x.to_s + ' ' + y.to_s
    }
  end
end

class Clock
  attr_reader :start

  def initialize(start)
    @start = start
  end

  def duration
    (Time::now - @start)
  end
end

context(:Route) {
  role :prices do
  end
  role :payable_position do
    def price_from(prev)
      return 0 unless prev
      delta = Math.sqrt((prev.x-payable_position.x)**2 + (prev.y-payable_position.y)**2 + (prev.z-payable_position.z)**2)
      road_type = @road_types[payable_position]
      price = prices[road_type]
      delta * price
    end
  end

  role :positions do
    def price_for_route(price_table)
      prev = nil
      sum = 0
      positions.each do |pos|
        bind :pos => :payable_position, :price_table => :prices
        sum += payable_position.price_from prev
        prev = payable_position
      end
      sum
    end
  end
  def update_position(new_position)
    positions << new_position
  end
  def calculate_price(start_time)
    price_table = prices[start_time.hour / (24/prices.length)]
    positions.price_for_route price_table
  end
  def initialize(prices, road_types)
    @positions = []
    @prices = prices
    @road_types = road_types
  end
}

class Road_types
  def initialize
    @road_types = {}
  end

  def []=(pos, road_type)
    t = @road_types[pos.x] ||= {}
    t = t[pos.y] ||= {}
    t[pos.z] = road_type
  end

  def [](pos)
    t = @road_types[pos.x]
    return 1 unless t
    t = t[pos.y]
    return 1 unless t
    t = t[pos.z]
    return 1 unless t
    t
  end
end

class Position
  attr_reader :x
  attr_reader :y
  attr_reader :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end
end

class MeterTest < Test::Unit::TestCase
  class TestClock
    def initialize(duration)
      @duration = duration

    end
    def start
      Time.now
    end
    attr_reader :duration
  end

  def test_run
    meter = Meter.new(TestClock.new(100),Position.new(0,0,0))
    price = meter.current_total Position.new(10,4,5)
    assert_equal(19,price.to_i)
  end
end