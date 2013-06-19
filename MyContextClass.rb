class MyContextClass
         def self.mul(x,y) (x * y) end
   def power(x,y) (x ** y) end
   def self.pow(x,y) (x ** y) end
   def self_rol_rolem(*args,&b) res = 0
args.each { |x| res = b.call(res, x) }
res
 end

           attr_reader :dummy, :rol
           end