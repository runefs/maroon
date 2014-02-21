c = context :AstRewritter do
  role :ast do
  end

  def initialize (ast, interpretation_context)
    @ast = AbstractSyntaxTree.new ast, interpretation_context
    @roles = interpretation_context.methods
  end

  def rewrite!
    ast.each_production { |production|

      case production.type
        when Tokens::rolemethod_call
          data = production.data
          production[2] = ('self_' + data[1].to_s + '_' + data[0].to_s).to_sym
          production[1] = nil
        when Tokens::block_with_bind
          block = production.last
          block.delete_at 1
          production.data.each do |local,aliased_role|
            must_b_sym = 'aliased_role must be a Symbol'.to_sym
            local_must_b_sym = 'local must be a Symbol'.to_sym
            raise must_b_sym unless aliased_role.instance_of? Symbol
            raise local_must_b_sym unless local.instance_of? Symbol
            unless @roles.has_key? aliased_role
              role_names = []
              @roles.each do |k,v|
                role_names << k.to_s if k != nil
              end
              raise aliased_role.to_s + ' is not a role. Available roles are ' + role_names.join(',')
            end
            # assigning role player to role field
            #notice that this will be executed after the next block
            aliased_field = ('@' + aliased_role.to_s).to_sym
            temp_symbol = ('temp____' + aliased_role.to_s).to_sym

            assignment = Sexp.new
            assignment[0] = :iasgn
            assignment[1] = aliased_field
            load_arg = Sexp.new
            load_arg[0] = :lvar
            load_arg[1] = local
            assignment[2] = load_arg
            block.insert 1, assignment

            # assign role player to temp
            # notice this is prepended Ie. inserted in front of the role player to role field
            assignment = Sexp.new
            assignment[0] = :lasgn
            assignment[1] = temp_symbol
            load_field = Sexp.new
            load_field[0] = :ivar
            load_field[1] = aliased_field
            assignment[2] = load_field
            block.insert 1, assignment

            # reassign original player
            assignment = Sexp.new
            assignment[0] = :iasgn
            assignment[1] = aliased_field
            load_temp = Sexp.new
            load_temp[0] = :lvar
            load_temp[1] = temp_symbol
            assignment[2] = load_temp
            block[block.length] = assignment
          end
        else
          #do nothing
      end
    }
  end

end

# context_class_code = c.generated_class
# 
# if context_class_code.instance_of? String
#   file_name = './generated/ast_rewritter.rb'
#   p "writing to: " + file_name
#   File.open(file_name, 'w') do |f|
#     f.write(context_class_code)
#   end
# end
