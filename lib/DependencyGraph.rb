class DependencyGraph
      def initialize(context_name,roles,interactions,dependencies) @context_name = context_name
@roles = roles
@interactions = interactions
@dependencies = dependencies
 end
 def create() nil end
     private

def self_dependencies_add(role_name,method_name) dependencies[role.name] = {} unless dependencies.has_key?(role.name)
unless dependencies.has_key?(role_name) then
  dependecies[role.name][role_name] = []
end
(dependecies[role.name][role_name] << method_name)
 end
   def self_role_get_dependencies() role.each_production do |production|
  name = nil
  method = nil
  case production.type
  when Tokens.rolemethod_call then
    data = production.data
    name = data[1]
    method = data[0]
  when Tokens.role then
    name = production.data[0]
  else
    # do nothing
  end
  self_dependencies_add(name, method) if name and name.to_sym.!=(role.name)
end end
attr_reader :roles, :interactions, :dependencies, :role

           end