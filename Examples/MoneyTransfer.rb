require './lib/maroon.rb'

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

  role :amount do
  end

  transfer do
    source.withdraw -amount
    destination.deposit amount
  end
end

class MoneyTransfer
  def initialize(source, destination, amount)
    @source = source
    @destination = destination
    @amount = amount
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