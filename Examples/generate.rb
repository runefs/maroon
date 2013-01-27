def this;
  self
end

@source
attr_reader :source

def self_source_withdraw amount

  source.movement(amount)
  self_source_log("withdrawal #{amount}")

end

private :self_source_withdraw

def self_source_log message
  p("role #{message}")
end

private :self_source_log
@destination
attr_reader :destination

def self_destination_deposit amount

  @destination.movement(amount)
  @destination.log("deposit #{amount}")

end

private :self_destination_deposit

def transfer amount

  self_source_withdraw(-amount)
  self_destination_deposit(amount)

end
