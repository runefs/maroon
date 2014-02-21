require_relative '../test_helper'

Context.define :MoneyTransfer do
  def initialize(source, destination, amount)
    @source = source
    @destination = destination
    @amount = amount
    @log = []
  end

  role :source do
    def withdraw(amount)
      source.movement(amount)
      source.log 'withdrawal ' + amount.to_s
    end
    def log(message)
      @log << (@source.to_s + ' source ' + message)
    end
  end

  role :destination do
    def deposit(amount)
      @destination.movement(amount)
      @destination.log 'deposit ' + amount.to_s
    end
    def logger(message)
      @log << @destination.to_s + ' destination ' + message
    end
  end

  role :amount do
  end

  def transfer
    source.withdraw -amount
    destination.deposit amount
  end
end

class Account
  def initialize (amount, id)
    @balance = amount
    @account_id = id
    @log = []
  end

  def movement(amount)
    log "Amount #{amount}"
    @balance+=amount
  end

  def log(message)
      @log << message
  end

  def balance
    @balance
  end

  def to_s
    "balance of #{@account_id}: #{@balance}"
  end
end


class MoneyTransferTest < Minitest::Test
  def test_transfer
    source = Account.new 1000, "source"
    destination = Account.new 0, "destination"
    ctx = MoneyTransfer.new source, destination, 100
    ctx.transfer
    assert_equal(900,source.balance)
    assert_equal(100,destination.balance)
  end
end