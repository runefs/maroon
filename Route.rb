class Route
         def update_position(new_position) (positions << new_position) end
   def calculate_price(start_time) price_table = prices[(start_time.hour / (24 / prices.length))]
positions.price_for_route(price_table)
 end
   def initialize(prices,road_types) @positions = []
@prices = prices
@road_types = road_types
 end
   def self_payable_position_price_from(prev) return 0 unless prev
delta = Math.sqrt(((((prev.x - payable_position.x) ** 2) + ((prev.y - payable_position.y) ** 2)) + ((prev.z - payable_position.z) ** 2)))
road_type = @road_types[payable_position]
price = prices[road_type]
(delta * price)
 end
   def self_positions_price_for_route(price_table) prev = nil
sum = 0
positions.each do |pos|
  temp____prices = @prices
  @prices = price_table
  temp____payable_position = @payable_position
  @payable_position = pos
  sum = (sum + payable_position.price_from(prev))
  prev = payable_position
  @payable_position = temp____payable_position
  @prices = temp____prices
end
sum
 end

           attr_reader :prices, :payable_position, :positions
           end