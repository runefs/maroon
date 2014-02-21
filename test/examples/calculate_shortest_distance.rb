context :CalculateShortestDistance do

  role :tentative_distance_values do
  end
  role :path do
  end

  role :current do
  end
  role :destination do
  end


  role :map do
    def distance_between(a, b)
      map.distances[Edge.new(a, b)]
    end

    # These two functions presume always travelling
    # in a southern or easterly direction
    def next_down_the_street_from(x)
      map.east_neighbor_of x
    end

    def next_along_the_avenue_from(x)
      map.south_neighbor_of x
    end
  end

  role :current do
    def tentative_distance
      tentative_distance_values[current]
    end
    def set_tentative_distance_to(x)
      tentative_distance_values[current] = x
    end
  end


  def rebind(origin_node, geometries)
    @current = origin_node
    @destination = geometries.destination
    @map = geometries
  end

  def distance
    current.set_tentative_distance_to(0)
    @path = CalculateShortestPath.new(current, destination, map,nil,nil,nil,nil).path
    retval = 0
    previous_node = nil
    path.reverse_each { |node|
      if previous_node.nil?
        retval = 0
      else
        retval += map.distance_between previous_node, node
      end
      previous_node = node
    }
    retval
  end

  def initialize(origin_node, geometries)
    rebind(origin_node, geometries)
    @tentative_distance_values = Hash.new
  end
end