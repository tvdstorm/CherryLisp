require 'glr/glr'
require 'glr/unparse'
require 'glr/rules-interp'

module GLR

  class UnboundSyntaxScopeError < RuntimeError
    def initialize(name)
      @name = name
    end

    def message
      return "syntax reference '#{@name}' is undefined"
    end
  end

  class TopLevelScopeError < RuntimeError 
    def initialize(name)
      @name = name
    end

    def message
      return "Syntax scope '#{@name}' cannot be entered."
    end
  end

  class ScopedExtensibleParser < Parser

    def initialize(grammar)
      super(grammar)
      @env = {}
      @env.default = []
      @syntax_scope_stack = []
    end    

    def reduction_hook(rulenode)
      super(rulenode)
      rule = rulenode.rule

      if rule.result == :Stat && rule.label == :extend_syntax_statement then
        add_rules_to_binding(rulenode)
      end

      if rule.result == :Stat && rule.label == :restrict_syntax_statement then
        remove_rules_from_binding(rulenode)
      end

      if rule.result == :SyntaxRef then
        #puts "Entering #{rule}: '#{Unparser.new(rulenode).text}'"
        enter_named_scope(rulenode)
      end

      if rule.result == :SyntaxJail then
        #puts "Exiting"
        exit_syntax_scope()
      end

    end

    private

    def remove_rules_from_binding(rulenode)
      # let syntax: Id "-=" GrammarExp
      # 0 = Id
      name = Unparser.new(rulenode.elements[0]).text
      rules = RulesInterpreter.new(rulenode).rules
      if toplevel?(name) then
        remove_rules_from_grammar(rules)
      else
        @env[name] -= rules
      end
    end

    def add_rules_to_binding(rulenode)
      # let syntax: Id "+=" GrammarExp
      # 0 = Id
      name = Unparser.new(rulenode.elements[0]).text
      rules = RulesInterpreter.new(rulenode).rules
      if toplevel?(name) then
        add_rules_to_grammar(rules)
      else
        @env[name] += rules
      end
    end

    def toplevel?(name)
      name == 'toplevel'
    end

    def enter_named_scope(rulenode)
      # Syntaxref: "[" Id "]"
      # 0 = "[" 1 = layout 2 = Id
      name = Unparser.new(rulenode.elements[2]).text
      raise TopLevelScopeError.new(name) if toplevel?(name)
      raise UnboundSyntaxScopeError.new(name) if !@env.has_key?(name) 
      enter_syntax_scope(@env[name])      
    end

    def enter_syntax_scope(rules)
      scoped_rules = filter_out_existing(rules)
      @syntax_scope_stack.push(scoped_rules)
      add_rules_to_grammar(scoped_rules)
    end

    def exit_syntax_scope()
      rules = @syntax_scope_stack.pop
      remove_rules_from_grammar(rules)
    end

    def add_rules_to_grammar(rules)
      grammar.add_rules(rules)
    end

    def remove_rules_from_grammar(rules)
      grammar.del_rules(rules)
    end

    def filter_out_existing(rules)
      rules.reject do |rule|
        grammar.contains_rule?(rule)
      end
    end

  end

end
