#
# --- Main Program: test driver
#


geometries = Manhattan_geometry1.new
path = CalculateShortestPath.new(geometries.root, geometries.destination, geometries)
print "Path is: "
path.each {
    |node|
  print "#{node.name} "
};
print "\n"
puts "distance is #{CalculateShortestDistance.new(geometries.root, geometries).distance}"

puts("")

geometries = ManhattanGeometry2.new
path = CalculateShortestPath.new(geometries.root, geometries.destination, geometries)
print "Path is: "
last_node = nil
path.each {
    |node|
  if last_node != nil;
    print " - #{geometries.distance_between(node, last_node)} - "
  end
  print "#{node.name}"
  last_node = node
};
print "\n"
puts "distance is #{CalculateShortestDistance.new(geometries.root, geometries.destination, geometries).distance}"