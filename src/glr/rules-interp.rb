
require 'glr/ast'
require 'ipg/rules'
require 'ipg/normalizer'

class RulesInterpreter
  # converts parsetrees representing rules to actual Rules

  def initialize(tree)
    @rules = []
    ast = Imploder.new(tree).ast
    ast.accept_visitor(self)
  end

  def rules
    @rules.inject([]) do |result, rule|
      result | Normalizer.new(rule).normalize
    end
  end

  def visit_appl_node(appl)
    env = {}
    if appl.match([:rule, [:Label?, :Result?, :Symbols?]], env) then
      label = env[:Label?].to_s.intern
      result = env[:Result?].to_s.intern
      elements = env[:Symbols?].collect do |sym|
        symbol_symbol(sym)
      end
      @rules << CFRule.new(label, result, elements)
    else
      appl.args.each do |arg|
        arg.accept_visitor(self)
      end
    end
  end

  def visit_list_node(list)
    list.each do |node|
      node.accept_visitor(self)
    end
  end

  def visit_str_node(str)
  end

  def visit_amb_node(amb)
    raise "Ambiguity node in rules interpreter!"
  end


  private

  def symbol_symbol(symbol_ast)
    env = {}
    if symbol_ast.match([:lit_symbol, [:Lit?]], env) then
      return env[:Lit?].inspect.intern
    elsif symbol_ast.match([:sort_symbol, [:Sort?]], env) then
      return env[:Sort?].to_s.intern
    elsif symbol_ast.match([:star_sep_symbol, [:Sort?, :Lit?]], env) then
      return (symbol_symbol(env[:Sort?]).to_s + ':' + env[:Lit?].inspect + '*').intern
    elsif symbol_ast.match([:plus_sep_symbol, [:Sort?, :Lit?]], env) then
      return (symbol_symbol(env[:Sort?]).to_s + ':' + env[:Lit?].inspect + '+').intern
    elsif symbol_ast.match([:star_symbol, [:Sort?]], env) then
      return (symbol_symbol(env[:Sort?]).to_s + '*').intern
    elsif symbol_ast.match([:plus_symbol, [:Sort?]], env) then
      return (symbol_symbol(env[:Sort?]).to_s + '+').intern
    else
      raise "Invalid symbol #{symbol_ast.inspect}"
    end
  end

end
