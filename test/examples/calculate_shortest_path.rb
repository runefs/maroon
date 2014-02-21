# -*- encoding: utf-8 -*-
#
# Consider street corners on a Manhattan grid. We want to find the
# minimal path from the most northeast city to the most
# southeast city. Use DijkstraTest's algorithm
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
# http://en.wikipedia.org/wiki/DijkstraTest's_algorithm
#
# and reads directly from the distance method, below


# Map as in cartography rather than Computer Science...
#
# Map is a DCI role. The role in this example is played by an
# object representing a particular Manhattan geometry
#Context::generate_files_in('.')

# c = context :CalculateShortestPath do
Context.define :CalculateShortestPath do

  # public initialize. It's overloaded so that the public version doesn't
  # have to pass a lot of crap; the initialize method takes care of
  # setting up internal data structures on the first invocation. On
  # recursion we override the defaults

  def initialize(origin_node, target_node, geometries,
      path_vector, unvisited_hash, pathto_hash,
      tentative_distance_values_hash)
    @destination = target_node

    rebind(origin_node, geometries)

    execute(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
  end


  role :distance_labeled_graph_node do
    # Access to roles and other Context data
    def tentative_distance_values
      tentative_distance_values
    end
    # Role Methods
    def tentative_distance
      tentative_distance_values[@distance_labeled_graph_node]
    end
    def set_tentative_distance_to(x)
      tentative_distance_values[@distance_labeled_graph_node] = x
    end
  end

  # These are handles to to the roles
  role :map do
    def distance_between(a, b)
      @map.distances[Edge.new(a, b)]
    end
    def next_down_the_street_from(x)
      east_neighbor_of x
    end
    def next_along_the_avenue_from(x)
      south_neighbor_of x
    end
    def origin
      map.root
    end
    def nearest_unvisited_node_to_target
      min = infinity
      selection = nil
      @unvisited.each_key {
          |intersection|
        bind :intersection => :distance_labeled_graph_node

        if @unvisited[distance_labeled_graph_node]
          tentative_distance = distance_labeled_graph_node.tentative_distance
          if tentative_distance < min

            min = tentative_distance
            selection = distance_labeled_graph_node
          end
        end
      }
      selection
    end
    def unvisited
      @unvisited
    end
  end

  role :current do
    # Access to roles and other Context data
    def unvisited
      map.unvisited
    end

    # Role Methods
    def unvisited_neighbors
      retval = Array.new
      if @south_neighbor != nil
        if unvisited[@south_neighbor] then
          retval << @south_neighbor
        end
      end
      if @east_neighbor != nil
        if unvisited[@east_neighbor] then
          retval << @east_neighbor
        end
      end

      retval
    end
    def tentative_distance
      @tentative_distance_values[current]
    end
  end
  role :unvisited do
  end


# This module serves to provide the methods both for the
# east_neighbor and south_neighbor roles

  role :neighbor_node do
    def relable_node_as(x)
      raise 'Argument cannot be nil' unless x
      raise 'self cannot be nil' unless @neighbor_node

      if x < neighbor_node.tentative_distance
        neighbor_node.set_tentative_distance_to x
        :distance_was_udated
      else
        :distance_was_not_udated
      end
    end

    # Role Methods
    def tentative_distance
      raise 'self cannot be nil' unless @neighbor_node
      tentative_distance_values[@neighbor_node]
    end
    def set_tentative_distance_to(x)
      raise 'Argument cannot be nil' unless x
      raise 'self cannot be nil' unless @neighbor_node
      tentative_distance_values[@neighbor_node] = x
    end
  end
# This is the method that starts the work. Called from initialize.

  def execute (path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
    do_inits(path_vector, unvisited_hash, pathto_hash,
             tentative_distance_values_hash)


    # Calculate tentative distances of unvisited neighbors

    unvisited_neighbors = current.unvisited_neighbors

    if unvisited_neighbors != nil
      unvisited_neighbors.each {
          |neighbor|
        bind :neighbor => :neighbor_node        
        tentative_distance = current.tentative_distance
        raise 'tentative distance cannot be nil' if tentative_distance == nil
        distance_between = map.distance_between(current, neighbor)
        raise 'distance between cannot be nil' if distance_between == nil
        net_distance = tentative_distance + distance_between

        if neighbor_node.relable_node_as(net_distance) == :distance_was_udated
          pathTo[neighbor] = @current
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

  def do_inits(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)

    # The conditional switches between the first and subsequent instances of the
    # recursion (the algorithm is recursive in graph contexts)
    if path_vector.nil?

      def do_inits(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
        # The conditional switches between the first and subsequent instances of the
        # recursion (the algorithm is recursive in graph contexts)
        if path_vector.nil?
          # Since path_vector isn't set up, this is the first iteration of the recursion
          @tentative_distance_values = Hash.new

          # This is the fundamental data structure for DijkstraTest's algorithm, called
          # Q in the Wikipedia description. It is a boolean hash that maps a
          # node onto false or true according to whether it has been visited

          @unvisited = Hash.new

          # These initializations are directly from the description of the algorithm
          map.nodes.each { |node| @unvisited[node] = true }
          @unvisited.delete(map.origin)
          map.nodes.each { |node| 
            bind :node => :distance_labeled_graph_node
            distance_labeled_graph_node.set_tentative_distance_to(infinity) }
          tentative_distance_values[map.origin] = 0

          # The path array is kept in the outermost context and serves to store the
          # return path. Each recurring context may add something to the array along
          # the way. However, because of the nature of the algorithm, individual
          # Context instances don't deliver partial paths as partial answers.
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

      # This is the fundamental data structure for DijkstraTest's algorithm, called
      # Q in the Wikipedia description. It is a boolean hash that maps a
      # node onto false or true according to whether it has been visited

      @unvisited = Hash.new

      # These initializations are directly from the description of the algorithm
      map.nodes.each { |node| @unvisited[node] = true }
      @unvisited.delete(map.origin)

      map.nodes.each { |node|
        bind :node => :distance_labeled_graph_node
        distance_labeled_graph_node.set_tentative_distance_to(infinity)
      }
      tentative_distance_values[map.origin] = 0


      # The path array is kept in the outermost context and serves to store the
      # return path. Each recurring context may add something to the array along
      # the way. However, because of the nature of the algorithm, individual
      # Context instances don't deliver partial paths as partial answers.

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


  def each
    path.each { |node| yield node }
  end


  def path
    @path
  end

  private

  def pathTo
    @pathTo
  end

  def east_neighbor;
    @east_neighbor
  end

  def south_neighbor;
    @south_neighbor
  end

  def destination;
    @destination
  end

  def tentative_distance_values;
    @tentative_distance_values
  end

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
