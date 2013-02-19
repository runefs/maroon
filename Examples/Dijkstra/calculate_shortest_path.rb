# -*- encoding: utf-8 -*-
require 'live_ast'
require 'live_ast/to_ruby'
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
 ctx,source = Context::define :CalculateShortestPath do
  role :distance_labeled_graph_node do
    # Access to roles and other Context data
    tentative_distance_values do
      tentative_distance_values
    end
    # Role Methods
    tentative_distance do
      tentative_distance_values[@distance_labeled_graph_node]
    end
    set_tentative_distance_to do |x|
      tentative_distance_values[@distance_labeled_graph_node] = x
    end
  end

  # These are handles to to the roles
  role :map do
    distance_between do |a, b|
      dist = @map.distances[Edge.new(a, b)]
     # p "distance between #{a.name} and #{b.name} is #{dist}"
      dist
    end
    next_down_the_street_from do |x|
      n = east_neighbor_of x
     # p "next down the street from #{x.name} is #{n.name}"
      n
    end
    next_along_the_avenue_from do |x|
      n = south_neighbor_of x
     # p "next along the avenue from #{x.name} is #{n.name}"
      n
    end
    origin do
      map.root
    end
    nearest_unvisited_node_to_target do
      min = infinity
      selection = nil
      @unvisited.each_key {
          |intersection|
        bind :intersection=>:distance_labeled_graph_node
        if @unvisited[intersection]
          tentative_distance = intersection.tentative_distance
          if tentative_distance < min
           # p "min distance is updated from #{min} to #{tentative_distance}"
            min = tentative_distance
            selection = intersection
          end
        end
      }
      selection
    end
    unvisited do
      @unvisited
    end
  end

  role :current do
    # Access to roles and other Context data
    unvisited do
      map.unvisited
    end

    # Role Methods
    unvisited_neighbors do
      retval = Array.new
      if @south_neighbor != nil
        if unvisited[@south_neighbor] then retval << @south_neighbor end
      end
      if @east_neighbor != nil
        if unvisited[@east_neighbor] then retval << @east_neighbor end
      end
     # p "unvisited neighbors #{retval}"
      retval
    end
    tentative_distance do
      raise "key (#{current}) not found in #{@tentative_distance_values}" unless @tentative_distance_values && (@tentative_distance_values.has_key? current)
      @tentative_distance_values[current]
    end
  end
  role :unvisited do  end


# This module serves to provide the methods both for the
# east_neighbor and south_neighbor roles

  role :neighbor_node do
    relable_node_as do |x|
      raise "Argument can't be nil" unless x
      raise "self can't be nil" unless @neighbor_node

      if x < neighbor_node.tentative_distance
       # p "updated tentative distance from #{neighbor_node.tentative_distance} to #{x}"
        neighbor_node.set_tentative_distance_to x
        :distance_was_udated
      else
       # p "left tentative distance at #{neighbor_node.tentative_distance} instead of #{x}"
        :distance_was_not_udated
      end
    end

    # Role Methods
    tentative_distance do
      raise "self can't be nil" unless @neighbor_node
      tentative_distance_values[@neighbor_node]
    end
    set_tentative_distance_to do |x|
      raise "Argument can't be nil" unless x
      raise "self can't be nil" unless @neighbor_node
      tentative_distance_values[@neighbor_node] = x
    end
  end
  # This is the method that starts the work. Called from initialize.

  execute do |path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash|
    do_inits(path_vector, unvisited_hash, pathto_hash,
             tentative_distance_values_hash)


    # Calculate tentative distances of unvisited neighbors

    unvisited_neighbors = current.unvisited_neighbors
   # p "#{unvisited_neighbors}"
    if unvisited_neighbors != nil
      unvisited_neighbors.each {
          |neighbor|
        bind :neighbor => :neighbor_node
        tentative_distance = current.tentative_distance
        raise "tentative distance can't be nil" if tentative_distance == nil
        distance_between = map.distance_between(current, neighbor)
        raise "distance between can't be nil" if distance_between == nil
        net_distance = tentative_distance + distance_between

        if neighbor.relable_node_as(net_distance) == :distance_was_udated
         # p "set path"
          pathTo[neighbor] = @current
         # p "path #{@pathTo}"
        end
      }
    end
    unvisited.delete(@current)

    # Are we done?
    if unvisited.size == 0
      save_path(@path)
    else
      # The next current node is the one with the least distance in the
      # unvisited set
      selection = map.nearest_unvisited_node_to_target


      # Recur
      CalculateShortestPath.new(selection, destination, map, path, @unvisited,
                                pathTo, tentative_distance_values)
    end
  end

  do_inits do |path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash|

    # The conditional switches between the first and subsequent instances of the
    # recursion (the algorithm is recursive in graph contexts)
    if path_vector.nil?

      def do_inits(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
        # The conditional switches between the first and subsequent instances of the
        # recursion (the algorithm is recursive in graph contexts)
        if path_vector.nil?
          # Since path_vector isn't set up, this is the first iteration of the recursion
          @tentative_distance_values = Hash.new

          # This is the fundamental data structure for Dijkstra's algorithm, called
          # "Q" in the Wikipedia description. It is a boolean hash that maps a
          # node onto false or true according to whether it has been visited

          @unvisited = Hash.new

          # These initializations are directly from the description of the algorithm
          map.nodes.each { |node| @unvisited[node] = true }
          @unvisited.delete(map.origin)
          map.nodes.each { |node| bind :node=>:distance_labeled_graph_node; node.set_tentative_distance_to(infinity) }
          tentative_distance_values[map.origin] = 0

          # The path array is kept in the outermost context and serves to store the
          # return path. Each recurring context may add something to the array along
          # the way. However, because of the nature of the algorithm, individual
          # Context instances don't deliver "partial paths" as partial answers.
          @path = Array.new

          # The pathTo map is a local associative array that remembers the
          # arrows between nodes through the array and erases them if we
          # re-label a node with a shorter distance

          @pathTo = Hash.new

        else

          # We are recurring. Just copy the values copied in from the previous iteration
          # of the recursion

          @tentative_distance_values = tentative_distance_values_hash
          @unvisited = unvisited_hash
          @path = path_vector
          @pathTo = pathto_hash
        end
      end
      # Since path_vector isn't set up, this is the first iteration of the recursion

      @tentative_distance_values = Hash.new

      # This is the fundamental data structure for Dijkstra's algorithm, called
      # "Q" in the Wikipedia description. It is a boolean hash that maps a
      # node onto false or true according to whether it has been visited

      @unvisited = Hash.new

      # These initializations are directly from the description of the algorithm
      map.nodes.each { |node| @unvisited[node] = true }
      @unvisited.delete(map.origin)
     # p "map #{map.nodes}"
      map.nodes.each { |node|
        bind :node => :distance_labeled_graph_node;
        node.set_tentative_distance_to(infinity)
       # p "initialized node #{node.name}"
      }
      tentative_distance_values[map.origin] = 0


      # The path array is kept in the outermost context and serves to store the
      # return path. Each recurring context may add something to the array along
      # the way. However, because of the nature of the algorithm, individual
      # Context instances don't deliver "partial paths" as partial answers.

      @path = Array.new

      # The pathTo map is a local associative array that remembers the
      # arrows between nodes through the array and erases them if we
      # re-label a node with a shorter distance

      @pathTo = Hash.new

    else

      # We are recurring. Just copy the values copied in from the previous iteration
      # of the recursion

      @tentative_distance_values = tentative_distance_values_hash
      @unvisited = unvisited_hash
      @path = path_vector
      @pathTo = pathto_hash
    end
  end
end

class CalculateShortestPath

  def pathTo
    @pathTo
  end
  def east_neighbor; @east_neighbor end
  def south_neighbor; @south_neighbor end
  def path; @path end

  def destination; @destination end
  def tentative_distance_values; @tentative_distance_values end

  # This is a shortcut to information that really belongs in the Map.
  # To keep roles stateless, we hold the Map's unvisited structure in the
  # Context object. We access it as though it were in the map


  # Initialization
  def rebind(origin_node, geometries)
    @current = origin_node
    @map = geometries

    @east_neighbor = map.east_neighbor_of(origin_node)
    @south_neighbor = map.south_neighbor_of(origin_node)
  end


  # public initialize. It's overloaded so that the public version doesn't
  # have to pass a lot of crap; the initialize method takes care of
  # setting up internal data structures on the first invocation. On
  # recursion we override the defaults

  def initialize(origin_node, target_node, geometries,
      path_vector = nil, unvisited_hash = nil, pathto_hash = nil,
      tentative_distance_values_hash = nil)
    @destination = target_node

    rebind(origin_node, geometries)

    execute(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
  end
  def each
    path.each { |node| yield node }
  end


  # This method does a simple traversal of the data structures (following pathTo)
  # to build the directed traversal vector for the minimum path

  def save_path(pathVector)
    node = destination
    begin
      pathVector << node
      node = pathTo[node]
    end while node != nil
  end
end

 File.open('CalculateShortestPath_generated.rb', 'w') {|f| f.write(source) }

