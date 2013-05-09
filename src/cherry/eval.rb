
# TODO: implement IPG etc in Cherry itself!

require 'cherry/pt2sexp'
require 'cherry/env'
require 'cherry/pair'
require 'cherry/primitive'
require 'ipg/normalizer'
require 'grammar/charclass'

class Cherry 
  CHERRY_GRAMMAR = 'cherry.boot'
  EVAL_WHEN_READ_SYMBOL = :"eval-when-read"

  attr_reader :parser

  def initialize()
    @parser = initial_parser
    @env = Environment.initial(self, @parser.grammar)
    eval(Pair.new(:load, Pair.new("prelude.chy", nil)))
  end

  def grammar
    @parser.grammar
  end

  def global_environment
    @env
  end
  
  def initial_parser
    grammar = BootstrapGrammar::Reader.from_file(CHERRY_GRAMMAR).grammar
    parser = GLR::Parser.new(grammar)
    parser.add_observer(self)
    return parser
  end

  def notify_reduction(rulenode)
    rule = rulenode.rule
    if rule.result == :Form && rule.label == :list then
      func = get_function_symbol(rulenode)
      unless func.nil? then
        sym = Unparser.new(func).text.to_sym
        if sym == EVAL_WHEN_READ_SYMBOL then
          form = CherryImploder.new(rulenode).ast
          result =  eval(Pair.new(:begin, form.rest), @env)
          rulenode.result = Pair.new(:quote, Pair.new(result, nil))
        end
      end
    end
  end

  def get_function_symbol(rulenode)
    # Skip over ( & layout and symbol nodes
    arg = rulenode.elements[2].possibilities[0].elements[0]
    unless arg.nil? then # if nil then rulenode = pt of ()
      return arg.possibilities[0].elements[0]
    end
    return nil
  end

  def normalize_ranges(sym, ranges)
    ranges.collect do |range|
      range.collect do |char|
        LexRule.new(:char, sym, [char])
      end
    end.flatten
  end


  def add_rule_to_grammar(x)
    # (rule cf pair Form ("(" Form "." Form ")"))
    # TODO: refactor rules and normalize to deal with sexp directly
    # preferably in Cherry itself...
    raise "Invalid arguments to rule: #{x}" if !x.is_a?(Pair)
    raise "Wrong number of arguments to rule: #{x}" if x.length != 4
    kind = x.first 
    label = x.second
    sort = x.third
    elts = x.fourth.to_a
    char_rules = []
    elts = elts.collect do |elt|
      if !elt.is_a?(Pair) then
        if elt.is_a?(String)
          ranges = CharClass.match(elt)
          if ranges then
            char_rules |= normalize_ranges(elt, ranges)
            elt
          else
            elt.inspect
          end
        else
          elt
        end
      else
        case elt.first
        when :star then
          args = elt.rest
          if args.length == 2 then
            "#{args[0]}:#{args[1].inspect}*"
          else
            "#{args[0]}*"
          end
        when :plus then
          args = elt.rest
          if args.length == 2 then
            "#{args[0]}:#{args[1].inspect}+"
          else
            "#{args[0]}+"
          end
        when :opt then
          "#{args[0]}?"
        else
          raise "Invalid grammar construct: #{elt.prin}"
        end
      end
    end   
    
    #puts "Sort: #{sort.inspect}"
    #puts "Label: #{label.inspect}"
    #puts "Elts: #{elts.inspect}"
    rules = []
    if kind == :lex then
      rules << LexRule.new(label, sort, elts)
    elsif kind == :cf then
      rules << CFRule.new(label, sort, elts)
    else
      raise "Invalid rule kind: #{kind}"
    end
    result = rules.inject([]) do |result, rule|
      result | Normalizer.new(rule).normalize
    end
    result += char_rules
    # TODO: filter out existing rules... (or is not needed?)
    grammar.add_rules(result)
  end
  
  def add_restriction(args)
    # (restrict Id [a-z])
    #puts "Adding restriction: #{args.inspect}"
    sym = args.first
    cc = args.second
    ranges = CharClass.match(cc)
    set = []
    ranges.each do |range|
      range.each do |char|
        set |= [char]
      end
    end
    grammar.add_restriction(sym, set)
  end

  def eval_string(str, env = @env)
    eval_form = Pair.new(:eval_string, Pair.new(str, nil))
    #puts "Evalling: #{eval_form.prin}"
    return eval(eval_form, env)
  end
  
  def eval(x, env = @env) 
    loop do
      #puts "Eval: #{x.prin}"
      if x.is_a?(Symbol) then
        return env.lookup(x)
      elsif !x.is_a?(Pair) then
        return x
      else 
        fun = x.first
        args = x.rest
        #puts ">> #{fun.prin} with #{args.prin}"
        case fun
        when :rule
          add_rule_to_grammar(args)
          return args
        when :restrict
          add_restriction(args)
          return nil
        when :quote
          return args.first
        when :begin 
          while !args.nil? && args.rest != nil do
            eval(args.first, env)
            args = args.rest
          end
          x = args.nil? ? nil : args.first;
        when :define 
          if args.first.is_a?(Pair) then
            lambda = Pair.new(:lambda, Pair.new(args.first.rest, 
                                                args.rest))
            return env.define(args.first.first, eval(lambda, env))
          else
            return env.define(args.first, eval(args.second, env));
          end
        when :set
          return env.set(args.first, eval(args.second, env))
        when :if 
          x = (eval(args.first, env) != false) ? args.second : args.third
        when :cond
          x = reduce_cond(args, env)
        when :lambda
          return Closure.new(args.first, args.rest, env)
        when :macro 
          #puts "ARGS: #{args.prin}"
          return Macro.new(args.first, args.rest, env)
        else # a call
          fun = eval(fun, env)
          if fun.is_a?(Macro) then
            x = fun.expand(self, x, args)
          elsif fun.is_a?(Closure) then
            x = fun.body
            env = Environment.new(fun.params, eval_list(args, env), fun.env)
          else
            #puts "FUN: #{fun.prin}"
            return fun.apply(self, eval_list(args, env))
          end
        end
      end
    end
  end

  def eval_list(list, env)
    return nil if list.nil?
    #puts "LIST: #{list.prin}"
    raise "Illegal arg list: #{list}" if !list.is_a?(Pair)
    return Pair.new(eval(list.first, env), eval_list(list.rest, env))
  end

  def reduce_cond(clauses, env)
    result = nil;
    loop do
      return false if clauses.nil? 
      clause = clauses.first;
      clauses = clauses.rest;

      if clause.first == :else ||
          (result = eval(clause.first, env)) == true then
        if clause.rest.nil? then
          return list(:quote, result)
        elsif clause.second == :"=>" then
          return list(clause.third, list(:quote, result))
        else
          return Pair.new(:begin, clause.rest)
        end
      end
    end
  end
  
  def list(x, y)
    Pair.new(x, Pair.new(y, nil))
  end

end

