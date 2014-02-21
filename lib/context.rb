class Context
  def self.define(*args, &block)
    name, base_class, default_interaction = *args
    if default_interaction and (not base_class.instance_of?(Class)) then
      base_class = eval(base_class.to_s)
    end
    if base_class and ((not default_interaction) and (not base_class.instance_of?(Class))) then
      base_class, default_interaction = default_interaction, base_class
    end
    @with_contracts ||= nil
    ctx = self.send(:create_context_factory, name, base_class, default_interaction, block)
    if self.generate_dependency_graph then
      dependencies = {}
      ctx.dependencies = DependencyGraphModel.new(DependencyGraph.new(name, ctx.methods, dependencies).create!)
    end    
    transformer = Transformer.new(name, ctx.methods, ctx.private_interactions, base_class, default_interaction)    
    ctx.generated_class = transformer.transform(generate_files_in, @with_contracts)
    ctx
  end

  def self.generate_files_in()
    @generate_files_in
  end

  def self.generate_files_in=(folder)
    @generate_files_in = folder
  end

  def self.generate_code=(value)
    @generate_code = value
  end

  def self.generate_dependency_graph=(value)
    @generate_dependency_graph = value
  end

  def self.generate_code()
    (@generate_code or ((not generate_dependency_graph) or generate_files_in))
  end

  def self.generate_dependency_graph()
    @generate_dependency_graph
  end

  def dependencies()
    @dependencies
  end

  def generated_class()
    @generated_class
  end

  def dependencies=(value)
    @dependencies = value
  end

  def generated_class=(value)
    @generated_class = value
  end

  def methods()
    @methods ||= {}
  end

  def private_interactions()
    @private_interactions
  end

  def get_sexp(b)
    begin
      b.to_sexp
    rescue NoMethodError => e
      if (e.message == "undefined method `[]' for nil:NilClass") then
        raise("It would seem you used a double quote somewhere which is unfortunately not supported")
      else
        raise(e)
      end
    end
  end

  def get_definitions(b)
    sexp = get_sexp(b)
    unless is_definition?(sexp[3]) then
      sexp = sexp[3]
      sexp = sexp.select { |exp| is_definition?(exp) } if sexp
      sexp ||= []
    end
    sexp.select { |exp| is_definition?(exp) }

  end

  def self.create_context_factory(name, base_class, default_interaction, block)
    ctx = Context.new(name, base_class, default_interaction)
    ctx.instance_eval do
      file, _ = block.source_location
      sexp = get_sexp(block)
      temp_block = sexp[3]
      i = 0
      
      unless temp_block then
        raise((("Could not parse '" + name.to_s) + "' try using '{|| }' for the context block and 'do'...'end' for the roles"))
      end
      while (i < temp_block.length) do
        exp = temp_block[i]

        # conditions changed due to updated format of sexp_processor gem used at sourcify 0.6.0
        unless temp_block[(i - 2)] and ((temp_block[(i - 2)][0] == :call) and (temp_block[(i - 2)][3][0] == :arglist)) then          
        
          if exp and ((exp[0] == :defn) or (exp[0] == :defs)) then
            add_method(exp, nil, file)
            temp_block.delete_at(i)
            i = (i - 1)
          else
            if exp and (exp[0] == :call) and ((exp[1] == nil) and (exp[2] == :private)) then
              @private = true
            end
          end
        end
        i = (i + 1)
      end
      ctx.instance_eval(&block)
    end
    ctx

  end

  def self.with_contracts(*args)
    return @with_contracts if (args.length == 0)
    value = args[0]
    if @with_contracts and (not value) then
      raise("make up your mind! disabling contracts during execution will result in undefined behavior")
    end
    @with_contracts = value

  end

  def is_definition?(exp)
    exp and ((exp[0] == :defn) or (exp[0] == :defs))
  end

  def role(role_name, &b)
    file_name, line_no = b.source_location
    @defining_role = Role.new(role_name, line_no, file_name)
    methods[role_name] ||= @defining_role
    if block_given? then
      definitions = get_definitions(b)
      file, line = b.source_location
      definitions.each { |exp| add_method(exp, nil, file) }
    end

  end

  def add_method(definition, line_no, file_name)
    name = if definition[1].instance_of?(Symbol) then
             definition[1]
           else
             ((definition[1].select { |e| e.instance_of?(Symbol) }.map { |e| e.to_s }.join(".") + ".") + definition[2].to_s).to_sym
           end
    key = (@defining_role == nil) ? (nil) : (@defining_role.name)
    unless @methods.has_key?(key) then
      if (@defining_role == nil) then
        @methods[key] = Role.new(nil, line_no, file_name)
      else
        raise(("Undefined role " + @defining_role.name.to_s))
      end
    end
    @methods[key].methods[name] = definition
    @private_interactions[name] = true if (@defining_role == nil) and @private    
  end

  def private()
    @private = true
  end

  def initialize(name, base_class, default_interaction)
    @methods = {}
    @private_interactions = {}
    @role_alias = {}
    @name = name
    @base_class = base_class
    @default_interaction = default_interaction

  end

  attr_reader :name, :base_class, :default_interaction
end