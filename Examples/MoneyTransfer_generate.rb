class MoneyTransfer
  
def rebind (origin_node, geometries)
current = origin_node
  ination = geometries.destination
  map = geometries end
  
def do_inits (path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
if path_vector.nil? then
    # Access to roles and other Context data
    # Role Methods
    # The conditional switches between the first and subsequent instances of the
    # recursion (the algorithm is recursive in graph contexts)
    def do_inits(path_vector, unvisited_hash, pathto_hash, tentative_distance_values_hash)
      if path_vector.nil? then
        @tentative_distance_values = Hash.new
        @unvisited = Hash.new
        map.nodes.each { |node| @unvisited[node] = true }
        @unvisited.delete(map.origin)
        map.nodes.each do |node|
          bind(:node, :Distance_labeled_graph_node)
          node.set_tentative_distance_to(infinity)
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
      temp____Distance_labeled_graph_node = @Distance_labeled_graph_node
      @Distance_labeled_graph_node = node
      temp____Distance_labeled_graph_node = @Distance_labeled_graph_node
      @Distance_labeled_graph_node = node
      self_Distance_labeled_graph_node_set_tentative_distance_to(infinity)
      @Distance_labeled_graph_node = temp____Distance_labeled_graph_node
      @Distance_labeled_graph_node = temp____Distance_labeled_graph_node
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
  
def transfer 
{ 1 => :one, 2 => :two }.each do |k, v|
    temp____destination = @destination
    @destination = v
    temp____source = @source
    @source = k
    self_source_log("in block")
    self_destination_logger("in block")
    @source = temp____source
    @destination = temp____destination
  end
  self_source_withdraw(-amount)
  self_destination_deposit(amount)
 end

@source
@destination
@Distance_labeled_graph_node
@amount

  private
def source;@source end
def destination;@destination end
def Distance_labeled_graph_node;@Distance_labeled_graph_node end
def amount;@amount end

  
def self_source_withdraw (amount)
source.movement(amount)
  self_source_log("withdrawal #{amount}") end
  
def self_source_log (message)
p("#{@source} source #{message}") end
  
def self_destination_deposit (amount)
@destination.movement(amount)
  @destination.log("deposit #{amount}") end
  
def self_destination_logger (message)
p("#{@source} destination #{message}") end
  
def self_Distance_labeled_graph_node_tentative_distance_values 
context.tentative_distance_values  end
  
def self_Distance_labeled_graph_node_tentative_distance 
tentative_distance_values[Distance_labeled_graph_node]  end
  
def self_Distance_labeled_graph_node_set_tentative_distance_to (x)
tentative_distance_values[Distance_labeled_graph_node] = x end


end