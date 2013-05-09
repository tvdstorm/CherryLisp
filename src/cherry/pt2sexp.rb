
require 'cherry/pair'


class CherryImploder
  attr_reader :ast

  class Ignored; end

  IGNORED = Ignored.new


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
    Pair.new(:quote, Pair.new(Pair.new(:amb, Pair.new(node.symbol, array2list(alts))), nil))
  end

  def visit_rule_node(node)
    if node.rule.label == :layout then
      return IGNORED
    end
    if node.rule.label == :lit then
      return IGNORED
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
    return node.string
  end

  private

  def array2list(array)
    if array.is_a?(Pair) then
      puts "A pair: #{array.prin}"
      return array
    end
    cons = nil
    array.reverse.each do |x|
      unless x === IGNORED then
        if x.is_a?(Array)
          x = array2list(x)
        end
        cons = Pair.new(x, cons)
      end
    end
    return cons
  end


  def implode_lexical(node)
    return Unparser.new(node).text
  end

  def implode_flattening(node)
    kids = []
    node.elements.each do |kid|
      new_kid = kid.accept_visitor(self)
      if new_kid.is_a?(Array) then
        kids += new_kid
      else
        kids << new_kid
      end
    end
    result = kids.reject { |x| x === IGNORED }
    #puts "Returning: #{result.inspect}"
    return result
    #return kids #.compact
  end

  def implode_default(node)
    return node.result unless node.result.nil?
    new_kids = []
    node.elements.each do |elt|
      kid = elt.accept_visitor(self)
      new_kids << kid unless kid === IGNORED
    end
    sym = node.rule.label.to_sym
    # NOTE: this way user constructor names will interfere with
    # the builtin ones (such as string)
    case sym
    when :top then return Pair.new(:begin, array2list(new_kids[0]))
    when :list then return array2list(new_kids[0])
    when :nil then return nil
    when :pair then 
      p = array2list(new_kids[0])
      p.rest = new_kids[1]
      return p #Pair.new(array2list(new_kids[0]), new_kids[1])
    when :string then return new_kids[0][1..-2] # strip off ""
    when :cclass then return new_kids[0]
    when :symbol then return new_kids[0].to_sym
    when :quote then return Pair.new(:quote, Pair.new(new_kids[0], nil))
    when :unquote then return Pair.new(:unquote, Pair.new(new_kids[0], nil))
    when :"unquote-splicing" then 
      return Pair.new(:"unquote-splicing", Pair.new(new_kids[0], nil))
    when :quasiquote then return Pair.new(:quasiquote, Pair.new(new_kids[0], nil))
    when :number then return Integer(new_kids[0])
    when :bool then return new_kids[0] == "#t" ? true : false
    else return Pair.new(sym, array2list(new_kids))
    end
  end
  



end
