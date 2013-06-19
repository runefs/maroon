class Meter
         def initialize(clock,start_pos) @clock = clock
@route = Route.new({ 0 => ({ 1 => 1.25 }) }, Road_types.new)
route.update_position(start_pos)
@price_per_sec = 0.05
 end
   def current_total(current_position) route.update_position(current_position)
(clock.price + route.price)
 end
   def print_route() route.each_point { |x, y| p(((x.to_s + " ") + y.to_s)) } end
   def self_route_price() route.calculate_price(clock.start) end
   def self_clock_price() (clock.duration * price_per_sec) end

           attr_reader :price_per_sec, :route, :clock
           end