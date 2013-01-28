def transfer (amount)
  self_source_withdraw(-amount)
  self_destination_deposit(amount)
end

@source
@destination

def initialize (source, destination)
  @source = source
  @destination = destination
end

private
def source;
  @source
end

def destination;
  @destination
end

def self_source_withdraw (amount)
  source.movement(amount)
  self_source_log("withdrawal #{amount}")
end

def self_source_log (message)
  p("role #{message}")
end

def self_destination_deposit (amount)
  @destination.movement(amount)
  @destination.log("deposit #{amount}")
end

