# -*- encoding: utf-8 -*-
require_relative '../test_helper'
require_relative 'data'
require_relative 'calculate_shortest_distance'
require_relative 'calculate_shortest_path'


class DijkstraTest < Minitest::Test
#!/usr/bin/env ruby
# Example in Ruby -- DijkstraTest's algorithm in DCI
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
  def test_geometry_1
    geometries = Geometry_1.new
    path = []
    CalculateShortestPath.new(geometries.root, geometries.destination, geometries,nil,nil,nil,nil).each { |node| path << "#{node.name} " }
    distance = CalculateShortestDistance.new(geometries.root, geometries).distance
    assert_equal(["'i' ","'h' ","'g' ","'d' ","'a' "], path)
    assert_equal(6,distance)
  end


  def test_geometry_2
    geometries = ManhattanGeometry2.new
    path = CalculateShortestPath.new(geometries.root, geometries.destination, geometries,nil,nil,nil,nil)
  
    last_node = nil
    res = []
    result = []
    path.each do |node|
      if last_node != nil;
        result << geometries.distances[Edge.new(node, last_node)]
      end
      res << "#{node.name}"
      last_node = node
    end
    assert_equal([1,1,3,2], result)
    assert_equal(["'k'", "'j'", "'c'", "'b'", "'a'"], res)
  end
end


