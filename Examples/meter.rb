require './lib/maroon'
require './lib/maroon/kernel'

context :Meter, :current_total do
   role :price_per_sec

   role :route do
        price do
          route.calculate_price clock.start
        end
   end

  role :clock do
    price do
      self.duration * price_per_sec
    end
  end

  current_total do |current_position|
    route.update_position current_position
    clock.price + route.price
  end
   print_route do
     route.each_point {|x,y|
       p "#{x},#{y}"
     }
   end
end

class Meter
  def initialize(start,start_pos)
    @clock = Clock.new start
    @route = Route.new({0=>{1=>1.25}},Road_types.new)
    route.update_position start_pos
    @price_per_sec = 0.05
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

context :Route do
  role :prices do end
  role :payable_position do
    price_from do |prev|
      return 0 unless prev
      delta = Math.sqrt((prev.x-self.x)**2 + (prev.y-self.y)**2 + (prev.z-self.z)**2)
      road_type = @road_types[self]
      p "road #{road_type}: prices #{prices}"
      price = prices[road_type]
      delta * price
    end
  end

  role :positions do
     price_for_route do |price_table|
       prev = nil
       sum = 0
       positions.each do |pos|
         bind pos=>:payable_position, price_table => :prices
         sum += pos.price_from prev
         prev = pos
       end
       sum
     end
  end
  update_position do |new_position|
    positions << new_position
  end
  calculate_price do |start_time|
     price_table = prices[start_time.hour / (24/prices.length)]
     positions.price_for_route price_table
  end
end

class Route
  def initialize(prices, road_types)
    @positions = []
    @prices = prices
    @road_types = road_types
  end
end

class Road_types
  def initialize
    @road_types = {}
  end
  def []=(pos,road_type)
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
  def initialize(x,y,z)
    @x = x
    @y = y
    @z = z
  end
end

meter = Meter.new Time::now, Position.new(1,2,0)
p meter.call Position.new(2,4,1)
