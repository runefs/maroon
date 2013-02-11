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
class ManhattanGeometry1 < ManhattanGeometry
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


    @a = nodes[0]
    @b = nodes[1]
    @c = nodes[2]
    @d = nodes[3]
    @e = nodes[4]
    @f = nodes[5]
    @g = nodes[6]
    @h = nodes[7]
    @i = nodes[8]

    9.times { |i|
      9.times { |j|
        distances[Edge.new(nodes[i], nodes[j])] = infinity
      }
    }

    distances[Edge.new(@a, @b)] = 2
    distances[Edge.new(@b, @c)] = 3
    distances[Edge.new(@c, @f)] = 1
    distances[Edge.new(@f, @i)] = 4
    distances[Edge.new(@b, @e)] = 2
    distances[Edge.new(@e, @f)] = 1
    distances[Edge.new(@a, @d)] = 1
    distances[Edge.new(@d, @g)] = 2
    distances[Edge.new(@g, @h)] = 1
    distances[Edge.new(@h, @i)] = 2
    distances[Edge.new(@d, @e)] = 1
    distances.freeze


    @next_down_the_street_from = Hash.new
    @next_down_the_street_from[@a] = @b
    @next_down_the_street_from[@b] = @c
    @next_down_the_street_from[@d] = @e
    @next_down_the_street_from[@e] = @f
    @next_down_the_street_from[@g] = @h
    @next_down_the_street_from[@h] = @i
    @next_down_the_street_from.freeze

    @next_along_the_avenue_from = Hash.new
    @next_along_the_avenue_from[@a] = @d
    @next_along_the_avenue_from[@b] = @e
    @next_along_the_avenue_from[@c] = @f
    @next_along_the_avenue_from[@d] = @g
    @next_along_the_avenue_from[@f] = @i
    @next_along_the_avenue_from.freeze
  end

  def east_neighbor_of(a); @next_down_the_street_from[a] end
  def south_neighbor_of(a); @next_along_the_avenue_from[a] end

  def root;  @a end
  def destination;  @i end
end


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
    @a = nodes[0]
    @b = nodes[1]
    @c = nodes[2]
    @d = nodes[3]
    @e = nodes[4]
    @f = nodes[5]
    @g = nodes[6]
    @h = nodes[7]
    @i = nodes[8]
    @j = nodes[9]
    @k = nodes[10]

    11.times { |i|
      11.times { |j|
        distances[Edge.new(nodes[i], nodes[j])] = infinity
      }
    }

    distances[Edge.new(@a, @b)] = 2
    distances[Edge.new(@b, @c)] = 3
    distances[Edge.new(@c, @f)] = 1
    distances[Edge.new(@f, @i)] = 4
    distances[Edge.new(@b, @e)] = 2
    distances[Edge.new(@e, @f)] = 1
    distances[Edge.new(@a, @d)] = 1
    distances[Edge.new(@d, @g)] = 2
    distances[Edge.new(@g, @h)] = 1
    distances[Edge.new(@h, @i)] = 2
    distances[Edge.new(@d, @e)] = 1
    distances[Edge.new(@c, @j)] = 1
    distances[Edge.new(@j, @k)] = 1
    distances[Edge.new(@i, @k)] = 2
    distances.freeze


    @next_down_the_street_from = Hash.new
    @next_down_the_street_from[@a] = @b
    @next_down_the_street_from[@b] = @c
    @next_down_the_street_from[@c] = @j
    @next_down_the_street_from[@d] = @e
    @next_down_the_street_from[@e] = @f
    @next_down_the_street_from[@g] = @h
    @next_down_the_street_from[@h] = @i
    @next_down_the_street_from[@i] = @k
    @next_down_the_street_from.freeze

    @next_along_the_avenue_from = Hash.new
    @next_along_the_avenue_from[@a] = @d
    @next_along_the_avenue_from[@b] = @e
    @next_along_the_avenue_from[@c] = @f
    @next_along_the_avenue_from[@d] = @g
    @next_along_the_avenue_from[@f] = @i
    @next_along_the_avenue_from[@j] = @k
    @next_along_the_avenue_from.freeze
  end

  def east_neighbor_of(a); @next_down_the_street_from[a] end
  def south_neighbor_of(a); @next_along_the_avenue_from[a] end

  def root;  @a end
  def destination;  @k end
end

