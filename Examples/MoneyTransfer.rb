require '../Moby'

Context::define :MoneyTransfer do
  role :source do
    withdraw do |amount|
      source.movement(amount)
      source.log "withdrawal #{amount}"
    end
    log do |message|
      p "role #{message}"
    end
  end

  role :destination do
    deposit do |amount|
      @destination.movement(amount)
      @destination.log "deposit #{amount}"
    end
  end

  role_or_interaction_method :transfer do |amount|
    source.withdraw -amount
    destination.deposit amount
  end

  def initialize(source, destination)
    @source = source
    @destination = destination
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
ctx = MoneyTransfer.new account, account
ctx.transfer 100
