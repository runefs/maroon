class MoneyTransfer
         def initialize(source,destination,amount) @source = source
@destination = destination
@amount = amount
@log = []
 end
   def transfer() source.withdraw(-amount)
destination.deposit(amount)
 end
   def self_source_withdraw(amount) source.movement(amount)
self_source_log(("withdrawal " + amount.to_s))
 end
   def self_source_log(message) (@log << ((@source.to_s + " source ") + message)) end
   def self_destination_deposit(amount) @destination.movement(amount)
@destination.log(("deposit " + amount.to_s))
 end
   def self_destination_logger(message) (@log << ((@destination.to_s + " destination ") + message)) end

           attr_reader :source, :destination, :amount
           end