class MyContextBlock
         def self_num_next() (num + 3) end
   def self_rol_rolem(*args,&b) res = 0
args.each do |x|
  temp____num = @num
  @num = x
  res = b.call(res, num.next)
  @num = temp____num
end
res
 end

           attr_reader :num, :rol
           end