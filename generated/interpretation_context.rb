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
    @roles = roles
    @contracts = contracts
    @role_aliases = role_aliases
    @defining_role = defining_role
  end
end