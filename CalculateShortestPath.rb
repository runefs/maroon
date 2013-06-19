class CalculateShortestPath
         def initialize(origin_node,target_node,geometries,path_vector,unvisited_hash,pathto_hash,tentative_distance_values_hash) @destination = target_node
rebind(origin_node, geometries)
execute(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
 end
   def execute(path_vector,unvisited_hash,pathto_hash,tentative_distance_values_hash) do_inits(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
unvisited_neighbors = current.unvisited_neighbors
if unvisited_neighbors.!=(nil) then
  unvisited_neighbors.each do |neighbor|
    temp____neighbor_node = @neighbor_node
    @neighbor_node = neighbor
    tentative_distance = current.tentative_distance
    raise("tentative distance cannot be nil") if (tentative_distance == nil)
    distance_between = map.distance_between(current, neighbor)
    raise("distance between cannot be nil") if (distance_between == nil)
    net_distance = (tentative_distance + distance_between)
    if (neighbor_node.relable_node_as(net_distance) == :distance_was_udated) then
      pathTo[neighbor] = @current
    end
    @neighbor_node = temp____neighbor_node
  end
end
unvisited.delete(@current)
if (unvisited.size == 0) then
  save_path(@path)
else
  selection = map.nearest_unvisited_node_to_target
  CalculateShortestPath.new(selection, destination, map, path, @unvisited, pathTo, tentative_distance_values)
end
 end
   def do_inits(path_vector,unvisited_hash,pathto_hash,tentative_distance_values_hash) if path_vector.nil? then
  def do_inits(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
    if path_vector.nil? then
      @tentative_distance_values = Hash.new
      @unvisited = Hash.new
      map.nodes.each { |node| @unvisited[node] = true }
      @unvisited.delete(map.origin)
      map.nodes.each do |node|
        temp____distance_labeled_graph_node = @distance_labeled_graph_node
        @distance_labeled_graph_node = node
        distance_labeled_graph_node.set_tentative_distance_to(infinity)
        @distance_labeled_graph_node = temp____distance_labeled_graph_node
      end
      tentative_distance_values[map.origin] = 0
      @path = Array.new
      @pathTo = Hash.new
    else
      @tentative_distance_values = tentative_distance_values_hash
      @unvisited = unvisited_hash
      @path = path_vector
      @pathTo = pathto_hash
    end
  end
  @tentative_distance_values = Hash.new
  @unvisited = Hash.new
  map.nodes.each { |node| @unvisited[node] = true }
  @unvisited.delete(map.origin)
  map.nodes.each do |node|
    temp____distance_labeled_graph_node = @distance_labeled_graph_node
    @distance_labeled_graph_node = node
    distance_labeled_graph_node.set_tentative_distance_to(infinity)
    @distance_labeled_graph_node = temp____distance_labeled_graph_node
  end
  tentative_distance_values[map.origin] = 0
  @path = Array.new
  @pathTo = Hash.new
else
  @tentative_distance_values = tentative_distance_values_hash
  @unvisited = unvisited_hash
  @path = path_vector
  @pathTo = pathto_hash
end end
   def each() path.each { |node| yield(node) } end
   def path() @path end
   def pathTo() @pathTo end
   def east_neighbor() @east_neighbor end
   def south_neighbor() @south_neighbor end
   def destination() @destination end
   def tentative_distance_values() @tentative_distance_values end
   def rebind(origin_node,geometries) @current = origin_node
@map = geometries
@east_neighbor = map.east_neighbor_of(origin_node)
@south_neighbor = map.south_neighbor_of(origin_node)
 end
   def save_path(pathVector) node = destination
begin
  (pathVector << node)
  node = pathTo[node]
end while node.!=(nil)
 end
   def self_distance_labeled_graph_node_tentative_distance_values() tentative_distance_values end
   def self_distance_labeled_graph_node_tentative_distance() tentative_distance_values[@distance_labeled_graph_node] end
   def self_distance_labeled_graph_node_set_tentative_distance_to(x) tentative_distance_values[@distance_labeled_graph_node] = x end
   def self_map_distance_between(a,b) @map.distances[Edge.new(a, b)] end
   def self_map_next_down_the_street_from(x) east_neighbor_of(x) end
   def self_map_next_along_the_avenue_from(x) south_neighbor_of(x) end
   def self_map_origin() map.root end
   def self_map_nearest_unvisited_node_to_target() min = infinity
selection = nil
@unvisited.each_key do |intersection|
  temp____distance_labeled_graph_node = @distance_labeled_graph_node
  @distance_labeled_graph_node = intersection
  if @unvisited[distance_labeled_graph_node] then
    tentative_distance = distance_labeled_graph_node.tentative_distance
    if (tentative_distance < min) then
      min = tentative_distance
      selection = distance_labeled_graph_node
    end
  end
  @distance_labeled_graph_node = temp____distance_labeled_graph_node
end
selection
 end
   def self_map_unvisited() @unvisited end
   def self_current_unvisited() self_current_unvisited end
   def self_current_unvisited_neighbors() retval = Array.new
if @south_neighbor.!=(nil) then
  (retval << @south_neighbor) if unvisited[@south_neighbor]
end
if @east_neighbor.!=(nil) then
  (retval << @east_neighbor) if unvisited[@east_neighbor]
end
retval
 end
   def self_current_tentative_distance() @tentative_distance_values[current] end
   def self_neighbor_node_relable_node_as(x) raise("Argument cannot be nil") unless x
raise("self cannot be nil") unless @neighbor_node
if (x < self_neighbor_node_tentative_distance) then
  self_neighbor_node_set_tentative_distance_to(x)
  :distance_was_udated
else
  :distance_was_not_udated
end
 end
   def self_neighbor_node_tentative_distance() raise("self cannot be nil") unless @neighbor_node
tentative_distance_values[@neighbor_node]
 end
   def self_neighbor_node_set_tentative_distance_to(x) raise("Argument cannot be nil") unless x
raise("self cannot be nil") unless @neighbor_node
tentative_distance_values[@neighbor_node] = x
 end

           attr_reader :distance_labeled_graph_node, :map, :current, :unvisited, :neighbor_node
           end