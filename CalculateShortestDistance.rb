class CalculateShortestDistance
         def rebind(origin_node,geometries) @current = origin_node
@destination = geometries.destination
@map = geometries
 end
   def distance() current.set_tentative_distance_to(0)
@path = CalculateShortestPath.new(current, destination, map, nil, nil, nil, nil).path
retval = 0
previous_node = nil
path.reverse_each do |node|
  if previous_node.nil? then
    retval = 0
  else
    retval = (retval + map.distance_between(previous_node, node))
  end
  previous_node = node
end
retval
 end
   def initialize(origin_node,geometries) rebind(origin_node, geometries)
@tentative_distance_values = Hash.new
 end
   def self_current_tentative_distance() tentative_distance_values[current] end
   def self_current_set_tentative_distance_to(x) tentative_distance_values[current] = x end
   def self_map_distance_between(a,b) map.distances[Edge.new(a, b)] end
   def self_map_next_down_the_street_from(x) map.east_neighbor_of(x) end
   def self_map_next_along_the_avenue_from(x) map.south_neighbor_of(x) end

           attr_reader :tentative_distance_values, :path, :current, :destination, :map
           end