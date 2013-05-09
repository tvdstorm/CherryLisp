require 'glr/unparse'
require 'glr/ast'

class Imploder
  attr_reader :ast

  def initialize(tree)
    @ast = tree.accept_visitor(self)
  end


  def visit_symbol_node(node)
    unless node.ambiguous? then
      return node.possibilities.first.accept_visitor(self)
    end
    alts = node.possibilities.collect do |pos|
      pos.accept_visitor(self)
    end
    AST::Amb.new(alts)
  end

  def visit_rule_node(node)
    if node.rule.label == :layout then
      return nil
    end
    if node.rule.label == :lit then
      return nil
    end
    if node.rule.lexical? then
      return implode_lexical(node)
    end
    if node.rule.label == :flatten then
      return implode_flattening(node)
    end
    return implode_default(node)
  end
  
  def visit_term_node(node)
    return AST::Str.new(node.string)
  end

  private

  def implode_lexical(node)
    return AST::Str.new(Unparser.new(node).text)
  end

  def flatten(kids, ast)
    return kids if not ast
    return kids + ast.elements if ast.is_a?(AST::List)
    return kids << ast
  end

  def implode_flattening(node)
    elts = node.elements.inject([]) do |kids, kid|
      flatten(kids, kid.accept_visitor(self))
    end
    AST::List.new(elts)
  end

  def implode_default(node)
    new_kids = []
    node.elements.each do |elt|
      kid = elt.accept_visitor(self)
      new_kids << kid if kid
    end
    AST::Appl.new(node.rule.label.to_sym, new_kids)
  end

end
