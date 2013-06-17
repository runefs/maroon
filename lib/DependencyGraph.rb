class DependencyGraph
  def initialize(context_name, roles, interactions, dependencies)
    @context_name = context_name
    @roles = roles
    @interactions = interactions
    @dependencies = dependencies
  end

  def create!()
    self_roles_dependencies
    self_interactions_dependencies
    dependencies
  end

  private

  def self_roles_dependencies()
    roles.each do |r, methods|
      temp____role_name = @role_name
      @role_name = r
      role_dependencies = dependencies[r] ||= {}
      if methods
        methods.each do |name, method_sources|
          temp____dependency = @dependency
          @dependency = role_dependencies
          temp____method = @method
          @method = method_sources
          self_method_get_dependencies
          @method = temp____method
          @dependency = temp____dependency
        end
      end
      @role_name = temp____role_name
    end
  end

  def self_interactions_dependencies()
    interactions.each do |name, interact|
      role_dependencies = dependencies[:interactions] ||= {}[name] ||= {}
      interact.each do |m|
        temp____dependency = @dependency
        @dependency = role_dependencies
        temp____method = @method
        @method = m
        self_method_get_dependencies
        @method = temp____method
        @dependency = temp____dependency
      end
    end
  end

  def self_dependency_add(dependent_role_name, method_name)
    if dependent_role_name and dependent_role_name.!=(role_name) then
      dependency[dependent_role_name] ||= {}
      unless dependency[dependent_role_name].has_key?(method_name) then
        dependency[dependent_role_name][method_name] = 0
      end
      dependency[dependent_role_name][method_name] += 1
    end
  end

  def self_method_body()
    args = self_method_definition.detect { |d| (d[0] == :args) }
    index = (self_method_definition.index(args) + 1)
    if (self_method_definition.length > (index + 1)) then
      body = self_method_definition[(index..-1)]
      body.insert(0, :block)
      body
    else
      self_method_definition[index]
    end
  end

  def self_method_ast()
    AbstractSyntaxTree.new(self_method_body, InterpretationContext.new(roles, {}, {}, role_name, {}))
  end

  def self_method_definition()
    method.instance_of?(Array) ? (method[0]) : (method)
  end

  def self_method_get_dependencies()
    self_method_ast.each_production do |production|
      name = nil
      method_name = nil
      case production.type
        when Tokens.rolemethod_call then
          data = production.data
          name = data[1]
          method_name = data[0]
        when Tokens.role then
          name = production.data[0]
        else
          # do nothing
      end
      self_dependency_add(name, method_name) if name.!=(nil)
    end
  end

  attr_reader :roles, :interactions, :dependencies, :dependency, :role_name, :method

end