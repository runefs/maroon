  
  def transfer (amount)
p 'transfer'

  [1, 2, 3, 4].each { |r| self_source_log("in block") }
  self_source_withdraw(-amount)
  self_destination_deposit(amount)
  end

@source
@destination

  private
def source;@source end
def destination;@destination end

  
  def self_source_withdraw (amount)
p 'self_source_withdraw'

  source.movement(amount)
  self_source_log("withdrawal #{amount}")
  end
  
  def self_source_log (message)
p 'self_source_log'
 p("role #{message}")   end
  
  def self_destination_deposit (amount)
p 'self_destination_deposit'

  @destination.movement(amount)
  @destination.log("deposit #{amount}")
  end

