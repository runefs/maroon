require '../Moby'

class MoneyTransfer < Context
  role :source do
    role_method :withdraw do |amount|
      source.movement(amount)
      source.log "withdrawal #{amount}"
    end
    role_method :log do |message|
      p "role #{message}"
    end
  end

  role :destination do
    role_method :deposit do |amount|
      @destination.movement(amount)
      @destination.log "deposit #{amount}"
    end
  end

  interaction :transfer do |amount|
    source.withdraw -amount
    destination.deposit amount
  end
  Context.finalize()

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
