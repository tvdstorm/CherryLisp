
require 'stringio'

class Dotter

  def self.to_dot(forest, stream = StringIO.new)
    forest.order # essential otherwise nodes have no id
    dot = Dotter.new(stream)
    forest.accept(dot)
    dot.dot
  end

  def initialize(stream)
    @stream = stream
    @nodes = []
    @edges = []
  end

  def dot(stream)
    @stream.puts "digraph parseforest {"
    @stream.puts "ordering=out"
    @nodes.each do |node|
      @stream.puts node
    end   
    @edges.each do |edge|
      @stream.puts edge
    end
    @stream.puts "}"
  end


  def visit_symbol_node(node)
    if node.symbol.to_s.inspect =~ /^"(.*)"$/ then
      label = $1
    else
      raise "Strange symbol: #{symbol.to_s.inspect}"
    end
    if node.possibilities.length == 1 then
      shape = "ellipse"
    else
      shape = "diamond"
    end
    id = dot_id(node)
    @nodes << "#{id} [label=\"#{label}\", shape=#{shape}]"
    node.possibilities.each do |pos|
      @edges << "#{id} -> #{dot_id(pos)}"
    end
  end

  def visit_rule_node(node)
    if rule.to_s.inspect =~ /^"(.*)"$/ then
      label = $1
    else
      raise "Strange rule: #{rule.to_s.inspect}"
    end
    id = dot_id(node)
    @nodes << "#{id} [label=\"#{label}\", shape=box]"
    node.elements.each do |elt|
      @edges << "#{id} -> #{dot_id(elt)}"
    end
  end

  def visit_term_node(node)
    if token.to_s.inspect =~ /^"(.*)"$/ then
      label = $1
    else
      raise "Strange string: #{string.inspect}"
    end
    id = dot_id(node)
    @nodes << "#{id} [label=\"#{label}\", shape=plaintext]"
  end

  private
  def dot_id(node)
    "node#{node.id}"
  end

end
