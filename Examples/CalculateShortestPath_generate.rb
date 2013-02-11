class CalculateShortestPath
  
def execute (path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
do_inits(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
  unvisited_neighbors = self_current_unvisited_neighbors
  unless (unvisited_neighbors == nil) then
    unvisited_neighbors.each do |neighbor|
      temp____neighbor_node = @neighbor_node
      @neighbor_node = neighbor
      tentative_distance = self_current_tentative_distance
      raise("tentative distance can't be nil") if (tentative_distance == nil)
      distance_between = self_map_distance_between(current, neighbor)
      raise("distance between can't be nil") if (distance_between == nil)
      net_distance = (tentative_distance + distance_between)
      if (self_neighbor_node_relable_node_as(net_distance) == :distance_was_udated) then
        pathTo[neighbor] = @current
      end
      @neighbor_node = temp____neighbor_node
    end
  end
  unvisited.delete(@current)
  if (unvisited.size == 0) then
    save_path(@path)
  else
    selection = self_map_nearest_unvisited_node_to_target
    CalculateShortestPath.new(selection, destination, map, path, @unvisited, pathTo, tentative_distance_values)
  end end
  
def do_inits (path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
if path_vector.nil? then
    # -*- encoding: utf-8 -*-
    #
    # Consider street corners on a Manhattan grid. We want to find the
    # minimal path from the most northeast city to the most
    # southeast city. Use Dijstra's algorithm
    #
    #
    # --------- Contexts: the home of the use cases for the example --------------
    #
    #
    # ---------- This is the main Context for shortest path calculation -----------
    #
    # There are eight roles in the algorithm:
    #
    # pathTo, which is the interface to whatever accumulates the path
    # current, which is the current intersection in the recursive algorithm
    # east_neighbor, which lies DIRECTLY to the east of current
    # south_neighbor, which is DIRECTLy to its south
    # destination, the target node
    # map, which is the oracle for the geometry
    # tentative_distance_values, which supports the algorithm, and is
    # owned by the CalculateShortestPath context (it is context data)
    #
    #
    # The algorithm is straight from Wikipedia:
    #
    # http://en.wikipedia.org/wiki/Dijkstra's_algorithm
    #
    # and reads directly from the distance method, below
    # "Map" as in cartography rather than Computer Science...
    #
    # Map is a DCI role. The role in this example is played by an
    # object representing a particular Manhattan geometry
    # Access to roles and other Context data
    # Role Methods
    # These are handles to to the roles
    # p "distance between #{a.name} and #{b.name} is #{dist}"
    # p "next down the street from #{x.name} is #{n.name}"
    # p "next along the avenue from #{x.name} is #{n.name}"
    # p "min distance is updated from #{min} to #{tentative_distance}"
    # Access to roles and other Context data
    # Role Methods
    # p "unvisited neighbors #{retval}"
    # This module serves to provide the methods both for the
    # east_neighbor and south_neighbor roles
    # p "updated tentative distance from #{neighbor_node.tentative_distance} to #{x}"
    # p "left tentative distance at #{neighbor_node.tentative_distance} instead of #{x}"
    # Role Methods
    # This is the method that starts the work. Called from initialize.
    # Calculate tentative distances of unvisited neighbors
    # p "#{unvisited_neighbors}"
    # p "set path"
    # p "path #{@pathTo}"
    # Are we done?
    # The next current node is the one with the least distance in the
    # unvisited set
    # Recur
    # The conditional switches between the first and subsequent instances of the
    # recursion (the algorithm is recursive in graph contexts)
    def do_inits(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
      if path_vector.nil? then
        @tentative_distance_values = Hash.new
        @unvisited = Hash.new
        map.nodes.each { |node| @unvisited[node] = true }
        @unvisited.delete(self_map_origin)
        map.nodes.each do |node|
          temp____distance_labeled_graph_node = @distance_labeled_graph_node
          @distance_labeled_graph_node = node
          self_distance_labeled_graph_node_set_tentative_distance_to(infinity)
          @distance_labeled_graph_node = temp____distance_labeled_graph_node
        end
        tentative_distance_values[self_map_origin] = 0
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
    @unvisited.delete(self_map_origin)
    map.nodes.each do |node|
      temp____distance_labeled_graph_node = @distance_labeled_graph_node
      @distance_labeled_graph_node = node
      self_distance_labeled_graph_node_set_tentative_distance_to(infinity)
      @distance_labeled_graph_node = temp____distance_labeled_graph_node
    end
    tentative_distance_values[self_map_origin] = 0
    @path = Array.new
    @pathTo = Hash.new
  else
    @tentative_distance_values = tentative_distance_values_hash
    @unvisited = unvisited_hash
    @path = path_vector
    @pathTo = pathto_hash
  end end

@distance_labeled_graph_node
@map
@current
@unvisited
@neighbor_node

  private
def distance_labeled_graph_node;@distance_labeled_graph_node end
def map;@map end
def current;@current end
def unvisited;@unvisited end
def neighbor_node;@neighbor_node end

  
def self_distance_labeled_graph_node_tentative_distance_values 
tentative_distance_values  end
  
def self_distance_labeled_graph_node_tentative_distance 
tentative_distance_values[@distance_labeled_graph_node]  end
  
def self_distance_labeled_graph_node_set_tentative_distance_to (x)
tentative_distance_values[@distance_labeled_graph_node] = x end
  
def self_map_distance_between (a, b)
dist = @map.distances[Edge.new(a, b)]
  dist end
  
def self_map_next_down_the_street_from (x)
n = east_neighbor_of(x)
  n end
  
def self_map_next_along_the_avenue_from (x)
n = south_neighbor_of(x)
  n end
  
def self_map_origin 
map.root  end
  
def self_map_nearest_unvisited_node_to_target 
min = infinity
  selection = nil
  @unvisited.each_key do |intersection|
    temp____distance_labeled_graph_node = @distance_labeled_graph_node
    @distance_labeled_graph_node = intersection
    if @unvisited[intersection] then
      tentative_distance = self_distance_labeled_graph_node_tentative_distance
      if (tentative_distance < min) then
        min = tentative_distance
        selection = intersection
      end
    end
    @distance_labeled_graph_node = temp____distance_labeled_graph_node
  end
  selection
 end
  
def self_map_unvisited 
@unvisited  end
  
def self_current_unvisited 
self_map_unvisited  end
  
def self_current_unvisited_neighbors 
retval = Array.new
  unless (@south_neighbor == nil) then
    (retval << @south_neighbor) if unvisited[@south_neighbor]
  end
  unless (@east_neighbor == nil) then
    (retval << @east_neighbor) if unvisited[@east_neighbor]
  end
  retval
 end
  
def self_current_tentative_distance 
unless @tentative_distance_values and @tentative_distance_values.has_key?(current) then
    raise("key (#{current}) not found in #{@tentative_distance_values}")
  end
  @tentative_distance_values[current]
 end
  
def self_neighbor_node_relable_node_as (x)
raise("Argument can't be nil") unless x
  raise("self can't be nil") unless @neighbor_node
  if (x < self_neighbor_node_tentative_distance) then
    self_neighbor_node_set_tentative_distance_to(x)
    :distance_was_udated
  else
    :distance_was_not_udated
  end end
  
def self_neighbor_node_tentative_distance 
raise("self can't be nil") unless @neighbor_node
  tentative_distance_values[@neighbor_node]
 end
  
def self_neighbor_node_set_tentative_distance_to (x)
raise("Argument can't be nil") unless x
  raise("self can't be nil") unless @neighbor_node
  tentative_distance_values[@neighbor_node] = x end


end