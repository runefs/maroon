def infinity; (2**(0.size * 8 -2) -1) end
# Data classes
Edge = Struct.new(:from, :to)

class Node
  attr_reader :name
  def initialize(n); @name = n end
  def eql? (another_node)
    # Nodes are == equal if they have the same name. This is explicitly
    # defined here to call out the importance of the differnce between
    # object equality and identity
    name == another_node.name
  end
end



#
# --- Geometry is the interface to the data class that has all
# --- the information about the map. This is kind of silly in Ruby
#
class ManhattanGeometry
  def initialize;
    @nodes = Array.new
    @distances = Hash.new
  end

  def nodes; @nodes end
  def distances
    @distances
  end
end



#
# --- Here are some test data
#

#noinspection RubyTooManyInstanceVariablesInspection
class Geometry_1 < ManhattanGeometry
  def initialize
    super()

    names = %w('a' 'b' 'c' 'd' 'a' 'b' 'g' 'h' 'i')

    3.times { |i|
      3.times { |j|
        nodes << Node.new(names[(i*3)+j])
      }
    }
    


    # Aliases to help set up the grid. Grid is of Manhattan form:
    #
    #    a - 2 - b - 3 - c
    #    |       |       |
    #    1       2       1
    #    |       |       |
    #    d - 1 - e - 1 - f
    #    |               |
    #    2               4
    #    |               |
    #    g - 1 - h - 2 - i
    #


    @node_a = nodes[0]
    @node_b = nodes[1]
    @node_c = nodes[2]
    @node_d = nodes[3]
    @node_e = nodes[4]
    @node_f = nodes[5]
    @node_g = nodes[6]
    @node_h = nodes[7]
    @node_i = nodes[8]

    9.times { |i|
      9.times { |j|
        distances[Edge.new(nodes[i], nodes[j])] = infinity
      }
    }

    distances[Edge.new(@node_a, @node_b)] = 2
    distances[Edge.new(@node_b, @node_c)] = 3
    distances[Edge.new(@node_c, @node_f)] = 1
    distances[Edge.new(@node_f, @node_i)] = 4
    distances[Edge.new(@node_b, @node_e)] = 2
    distances[Edge.new(@node_e, @node_f)] = 1
    distances[Edge.new(@node_a, @node_d)] = 1
    distances[Edge.new(@node_d, @node_g)] = 2
    distances[Edge.new(@node_g, @node_h)] = 1
    distances[Edge.new(@node_h, @node_i)] = 2
    distances[Edge.new(@node_d, @node_e)] = 1
    distances.freeze


    @next_down_the_street_from = Hash.new
    @next_down_the_street_from[@node_a] = @node_b
    @next_down_the_street_from[@node_b] = @node_c
    @next_down_the_street_from[@node_d] = @node_e
    @next_down_the_street_from[@node_e] = @node_f
    @next_down_the_street_from[@node_g] = @node_h
    @next_down_the_street_from[@node_h] = @node_i
    @next_down_the_street_from.freeze

    @next_along_the_avenue_from = Hash.new
    @next_along_the_avenue_from[@node_a] = @node_d
    @next_along_the_avenue_from[@node_b] = @node_e
    @next_along_the_avenue_from[@node_c] = @node_f
    @next_along_the_avenue_from[@node_d] = @node_g
    @next_along_the_avenue_from[@node_f] = @node_i
    @next_along_the_avenue_from.freeze
  end

  def east_neighbor_of(a); @next_down_the_street_from[a] end
  def south_neighbor_of(a); @next_along_the_avenue_from[a] end

  def root;  @node_a end
  def destination;  @node_i end
end


#noinspection RubyTooManyInstanceVariablesInspection
class ManhattanGeometry2 < ManhattanGeometry
  def initialize
    super()
    names = %w('a' 'b' 'c' 'd' 'a' 'b' 'g' 'h' 'i' 'j' 'k')

    11.times { |j| nodes << Node.new(names[j]) }


    # Aliases to help set up the grid. Grid is of Manhattan form:
    #
    #    a - 2 - b - 3 - c - 1 - j
    #    |       |       |       |
    #    1       2       1       |
    #    |       |       |       |
    #    d - 1 - e - 1 - f       1
    #    |               |       |
    #    2               4       |
    #    |               |       |
    #    g - 1 - h - 2 - i - 2 - k


    #
    @node_a = nodes[0]
    @node_b = nodes[1]
    @node_c = nodes[2]
    @node_d = nodes[3]
    @node_e = nodes[4]
    @node_f = nodes[5]
    @node_g = nodes[6]
    @node_h = nodes[7]
    @node_i = nodes[8]
    @node_j = nodes[9]
    @node_k = nodes[10]

    11.times { |i|
      11.times { |j|
        distances[Edge.new(nodes[i], nodes[j])] = infinity
      }
    }

    distances[Edge.new(@node_a, @node_b)] = 2
    distances[Edge.new(@node_b, @node_c)] = 3
    distances[Edge.new(@node_c, @node_f)] = 1
    distances[Edge.new(@node_f, @node_i)] = 4
    distances[Edge.new(@node_b, @node_e)] = 2
    distances[Edge.new(@node_e, @node_f)] = 1
    distances[Edge.new(@node_a, @node_d)] = 1
    distances[Edge.new(@node_d, @node_g)] = 2
    distances[Edge.new(@node_g, @node_h)] = 1
    distances[Edge.new(@node_h, @node_i)] = 2
    distances[Edge.new(@node_d, @node_e)] = 1
    distances[Edge.new(@node_c, @node_j)] = 1
    distances[Edge.new(@node_j, @node_k)] = 1
    distances[Edge.new(@node_i, @node_k)] = 2
    distances.freeze


    @next_down_the_street_from = Hash.new
    @next_down_the_street_from[@node_a] = @node_b
    @next_down_the_street_from[@node_b] = @node_c
    @next_down_the_street_from[@node_c] = @node_j
    @next_down_the_street_from[@node_d] = @node_e
    @next_down_the_street_from[@node_e] = @node_f
    @next_down_the_street_from[@node_g] = @node_h
    @next_down_the_street_from[@node_h] = @node_i
    @next_down_the_street_from[@node_i] = @node_k
    @next_down_the_street_from.freeze

    @next_along_the_avenue_from = Hash.new
    @next_along_the_avenue_from[@node_a] = @node_d
    @next_along_the_avenue_from[@node_b] = @node_e
    @next_along_the_avenue_from[@node_c] = @node_f
    @next_along_the_avenue_from[@node_d] = @node_g
    @next_along_the_avenue_from[@node_f] = @node_i
    @next_along_the_avenue_from[@node_j] = @node_k
    @next_along_the_avenue_from.freeze
  end

  def east_neighbor_of(a); @next_down_the_street_from[a] end
  def south_neighbor_of(a); @next_along_the_avenue_from[a] end

  def root;  @node_a end
  def destination;  @node_k end
end

