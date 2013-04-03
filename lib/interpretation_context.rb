class InterpretationContext
  def contracts
    (@contracts ||= {})
  end
  def roles
    (@roles ||= {})
  end
  def role_aliases
    (@role_aliases ||= {})
  end
  def defining_role
    @defining_role
  end
  def initialize(roles,contracts,role_aliases,defining_role)
    raise "Aliases must be a hash" unless role_aliases.instance_of? Hash or role_aliases == nil
    raise "Roles must be a hash" unless roles.instance_of? Hash or roles == nil
    raise "Contracts must be a hash" unless contracts.instance_of? Hash or contracts == nil

    @roles = roles
    raise "Defining role is undefined" if defining_role && (!self.roles.has_key? defining_role)

    @contracts = contracts
    @role_aliases = role_aliases
    @defining_role = defining_role
  end
end