class Tokens
  def self.define_token(name)
    class_eval("@@#{name} = Tokens.new :#{name};def Tokens.#{name};@@#{name};end")
  end

  def to_s
    @type.to_s
  end

  private
  def initialize(type)
    @type = type
    self.freeze
  end

  define_token :terminal
  define_token :role
  define_token :rolemethod_call
  define_token :other
  define_token :call
  define_token :indexer
  define_token :block
  define_token :block_with_bind
end