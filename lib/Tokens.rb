class Tokens
  def self.define_token(name)
    class_eval %{
      @#{name} = Tokens.new :#{name};
      def Tokens.#{name}
        @#{name}
      end
    }
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
  define_token :initializer
  define_token :const
end

class DependencyGraphModel

  def initialize(dependencies)
    @dependencies = dependencies
  end

  def to_hash
    @dependecies
  end

  def to_s
    print_dependencies @dependencies, 0
  end

  def to_dot
    res = ''
    dependencies = denormalize @dependencies
    dependencies.each { |d| res << d.reverse.join('->') << '
    ' }
    'digraph g{
    ' + res + '}'
  end

  private
  def print_dependencies(dependencies, indent)
    res = ''
    dependencies.each do |key, value|
      res << key.to_s
      if value.instance_of? Hash
        res << '->' << (print_dependencies value, indent != nil ? indent+4 : nil)
      elsif res << ':' << value.to_s + '
      '
        indent.times { res << ' ' } unless indent == nil
      end
      res << '
      '
    end
    res
  end

  def denormalize(dependencies)
    res = []
    dependencies.each do |key, value|
      if value.instance_of? Hash
        res = denormalize value
        res.each { |a| a << key }
      else
        res << [key]
      end
    end
    res
  end
end

class Role
  def initialize(name, line_no, file_name)
    raise "Roles must indicate a location" if name && ((line_no == nil) || file_name == nil)
    @methods = {}
    @name = name
    @line_no = line_no
    @file_name = file_name
  end

  def method_defined? name
    @methods.has_key? name
  end

  attr_reader :name, :methods, :line_no, :file_name
end