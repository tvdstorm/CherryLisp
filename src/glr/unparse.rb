
class Unparser
  attr_reader :text

  def initialize(tree)
    @text = tree.accept_visitor(self)
  end

  def visit_rule_node(node)
    node.elements.collect do |elt|
      elt.accept_visitor(self)
    end.join
  end

  def visit_symbol_node(node)
    node.possibilities.first.accept_visitor(self)
  end

  def visit_term_node(node)
    node.string
  end

end
