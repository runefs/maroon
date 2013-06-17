class InterpretationContext

  attr_reader :contracts, :methods, :role_aliases, :defining_role, :private_interactions

  def initialize(methods, contracts, role_aliases, defining_role, private_interactions)
    raise "Aliases must be a hash" unless role_aliases.instance_of? Hash or role_aliases == nil
    raise "Roles must be a hash" unless methods.instance_of? Hash or methods == nil
    raise "Contracts must be a hash" unless contracts.instance_of? Hash or contracts == nil

    @methods = methods
    if defining_role && defining_role.name && (!self.methods.has_key? defining_role.name)
      raise "Defining role '" + (defining_role.name.to_s || '') + "' is not defined in: " + self.methods.to_s
    end

    @contracts = contracts
    @role_aliases = role_aliases
    @defining_role = defining_role
    @private_interactions = private_interactions

  end
end