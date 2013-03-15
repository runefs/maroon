# -*- encoding: utf-8 -*-
require './Lib/maroon.rb'
require './Examples/Dijkstra/data.rb'
require './Examples/Dijkstra/CalculateShortestDistance.rb'
require './Examples/Dijkstra/Calculate_Shortest_Path.rb'
#!/usr/bin/env ruby
# Example in Ruby -- Dijkstra's algorithm in DCI
#    Modified and simplified for a Manhattan geometry with 8 roles
#
#
#
# Demonstrates an example where:
#
#    - objects of class Node play several roles simultaneously
#      (albeit spread across Contexts: a Node can
#      play the CurrentIntersection in one Context and an Eastern or
#      Southern Neighbor in another)
#    - stacked Contexts (to implement recursion)
#     - mixed access of objects of Node through different
#      paths of role elaboration (the root is just a node,
#      whereas others play roles)
#    - there is a significant pre-existing data structure called
#      a Geometry (plays the Map role) which contains the objects
#      of instance. Where DCI comes in is to ascribe roles to those
#      objects and let them interact with each other to evaluate the
#      minimal path through the network
#    - true to core DCI we are almost always concerned about
#      what happens between the objects (paths and distance)
#      rather than in the objects themselves (which have
#      relatively uninteresting properties like "name")
#    - equality of nodes is not identity, and several
#      nodes compare equal with each other by standard
#      equality (eql?)
#    - returns references to the original data objects
#      in a vector, to describe the resulting path
#
# There are some curiosities
#
#    - east_neighbor and south_neighbor were typographically equivalent,
#      so I folded them into a single role: Neighbor. That type still
#      serves the two original roles
#    - Roles are truly scoped to the use case context
#    - The Map and Distance_labeled_graph_node roles have to be
#      duplicated in two Contexts. blah blah blah
#    - Node inheritance is replaced by injecting two roles
#       into the object
#    - Injecting roles no longer adds new fields to existing
#       data objects.
#    - There is an intentional call to distance_between while the
#       Context is still extant, but outside the scope of the
#       Context itself. Should that be legal?
#    - I have added a tentative_distance_values array to the Context
#       to support the algorithm. Its data are shared across the
#       roles of the CalculateShortestPath Context
#    - nearest_unvisited_node_to_target is now a feature of Map,
#       which seems to reflect better coupling than in the old
#       design


# --- Main Program: test driver
#
geometries = Geometry_1.new
path = CalculateShortestPath.new(geometries.root, geometries.destination, geometries)
print 'Path is: '
path.each { |node| print "#{node.name} " }
print "\n"
puts "distance is #{CalculateShortestDistance.new(geometries.root, geometries).distance}"

puts ''

geometries = ManhattanGeometry2.new
path = CalculateShortestPath.new(geometries.root, geometries.destination, geometries)
print 'Path is: '
last_node = nil
path.each do |node|
  if last_node != nil;
    print " - #{geometries.distances[Edge.new(node, last_node)]} - "
  end
  print "#{node.name}"
  last_node = node
end
print "\n"

geometries = ManhattanGeometry2.new
puts "distance is #{CalculateShortestDistance.new(geometries.root, geometries).distance }"
