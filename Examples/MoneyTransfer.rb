require '../lib/Moby'

Context::define :MoneyTransfer do
  role :source do
    withdraw do |amount|
      source.movement(amount)
      source.log "withdrawal #{amount}"
    end
    log do |message|
      p "#{@source} source #{message}"
    end
  end

  role :destination do
    deposit do |amount|
      @destination.movement(amount)
      @destination.log "deposit #{amount}"
    end
    logger do |message|
      p "#{@source} destination #{message}"
    end
  end

  role :Distance_labeled_graph_node do
    # Access to roles and other Context data
    tentative_distance_values do
      context.tentative_distance_values
    end
    # Role Methods
    tentative_distance do
      tentative_distance_values[Distance_labeled_graph_node]
    end
    set_tentative_distance_to do |x|
      tentative_distance_values[Distance_labeled_graph_node] = x
    end
  end

  role :amount do end

  rebind do |origin_node, geometries|
    current = origin_node
    ination = geometries.destination
    map = geometries
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
          map.nodes.each { |node| bind :node,:Distance_labeled_graph_node; node.set_tentative_distance_to(infinity) }
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
      map.nodes.each { |node|
        bind :node => :Distance_labeled_graph_node,:node => :Distance_labeled_graph_node
        node.set_tentative_distance_to(infinity)
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

  transfer do
    {1=>:one,2=>:two}.each do |k,v|
      bind k=> :source,v=>:destination
      k.log 'in block'
      v.logger 'in block'
    end

    source.withdraw -amount
    destination.deposit amount
  end
end

class MoneyTransfer
  def initialize(source, destination, amount)
    @source = source
    @destination = destination
    @amount  = amount
  end
end
class Account
  def initialize (amount, id)
    @balance = amount
    @account_id = id
  end

  def movement(amount)
    log "Amount #{amount}"
    @balance+=amount
  end

  def log(message)
    (p s = "instance #{message}")
  end

  def to_s
    "balance of #{@account_id}: #{@balance}"
  end
end

account = Account.new 1000, "source"
ctx = MoneyTransfer.new account, account, 100
ctx.transfer
