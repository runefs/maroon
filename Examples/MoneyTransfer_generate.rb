class MoneyTransfer
  
def transfer 
self_source_withdraw(-amount)
  self_destination_deposit(amount)
 end

@source
@destination
@amount

  private
def source;@source end
def destination;@destination end
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


end