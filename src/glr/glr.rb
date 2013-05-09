# Notes:
# (mapc f l) = l.each &f
# (mapcar f l) = l.collect &f
# (newl a b) = a.unshift(b)
# (nextl a b) = a.shift(b)
# (memq x l) = l.include?(x)
# (any f l) = l.detect &f (??)
# (assq v l) = l.has_key?(v) (??)
# (cassq v l) = l[v] (??)
# Check omakeq argument order (especially when keywords are used)

# Design:
# Grammar: captures grammar/parsetable
#    External interface: add_rule, del_rule, action, goto etc.
# Parser: initialized with a grammar, parse(string) returns graph

require 'pp'

require 'glr/stack'
require 'glr/forest'

module GLR
 
  class ParseError < RuntimeError
    def initialize(token, position, line, column)
      @token = token
      @positions = position
      @line = line
      @column = column
    end
    def message
      "Token '#{@token}' unexpected at line #{@line}, column #{@column}"
    end
  end

  class Parser
    attr_reader :grammar

    def initialize(grammar)
      @grammar = grammar
      @observers = []
      reset
    end

    def reset
      @tokens = []
      @result = nil
      @position = 0
      @line = 1
      @column = 0
    end

    def feed(string)
      add_tokens(string.split(''))
    end

    def add_observer(obs)
      @observers << obs
    end

    def parse_with_grammar(grammar, string)
      parser = Parser.new(grammar)
      return parser.parse(string)
    end

    def parse(string = nil)
      if string then
        reset
        feed(string)
      end
      add_tokens([:EOF])
      stacknode = StackNode.new(grammar.start_state)
      parsers = [stacknode]
      while not parsers.empty? do
        parsers = parseword(parsers)
      end      
      if @result then
        return @result.stacklinks.first.treenode
      end
      raise ParseError.new(@token, @position, @line, @column)
    end
    

    def add_tokens(tokens)
      @tokens += tokens
    end

    def shift_token
      token = @tokens.shift
      if token == "\n" then
        @line += 1
        @column = 0
      else
        @column += 1
      end
      return token
    end


    def parseword(active_parsers)
      @active_parsers = active_parsers
      # This seems dangerous, however with .clone
      # empty lists for X* are not parsed
      @for_actor = @active_parsers #.clone
      @token = shift_token
      @generated_rulenodes = []
      @generated_symbolnodes = []
      @for_shifter = []
      while not @for_actor.empty? do 
        actor(@for_actor.shift)
      end
      return shifter(@for_shifter, @token, @position += 1)
    end


    def schedule_for_shifter(parser, state)
      @for_shifter << [parser, state]
    end

    def set_result(parser)
      @result = parser
    end

    def actor(parser)
      parser.actions(@token).each do |action|
        action.react(parser, self)
      end
    end

    def do_reductions(stacknode, treenodes, length, rule, 
                      link_to_see = true, link_seen = true)
      if length == 0 then
        if link_seen then
          reducer(stacknode, treenodes, rule)
        end
      else
        stacknode.each_link do |link|
          do_reductions(link.backlink, 
                        [link.treenode] + treenodes,
                        length - 1,
                        rule,
                        link_to_see,
                        link_seen || (link == link_to_see))
        end
      end
    end
    

    def reduction_hook(rulenode)
      @observers.each do |obs|
        obs.notify_reduction(rulenode)
      end
    end

    def reducer(stacknode_1, treenodes, rule)
      symbol = rule.result
      label = rule.label
      rulenode = get_rulenode(rule, treenodes)

      return if grammar.follow_restricted?(symbol, @token)
      return if grammar.priorities_violated?(rule, treenodes)

      state = stacknode_1.goto(symbol)
      return unless state

      reduction_hook(rulenode)

      stacknode = get_stacknode(@active_parsers, state)
      if stacknode then
        found = false
        stacknode.each_link do |link|
          if stacknode_1 == link.backlink &&
              link.treenode.is_a?(SymbolNode)
            add_rulenode(link.treenode, rulenode)
            found = true
          end
        end
        if not found then
          link = StackLink.new(get_symbolnode(symbol, rulenode), stacknode_1)
          stacknode.unshift(link)
          @active_parsers.each do |sn|
            unless @for_actor.include?(sn) then
              #puts @for_actor.join(", ")
              sn.actions(@token) do |action|
                if action.is_a?(Reduce) then
                  do_reductions(sn, [], action.rule.length, 
                                action.rule, link, false)
                end
                #action.reduce_again(sn, link, self)
              end
            end
          end
        end
      else
        stacknode = StackNode.new(state, 
                                  [StackLink.new(get_symbolnode(symbol, rulenode),
                                                 stacknode_1)])
        @for_actor.unshift(stacknode)
        # for_actor shadows active parsers
        # See above where clone couldn't be used...
        # @active_parsers.unshift(stacknode)
      end
    end

    def shifter(for_shifter, token, position)
      new_active_parsers = []
      termnode = TermNode.new(token, token.to_s, [position, position])
      for_shifter.each do |stacknode_1, state|
        link = StackLink.new(termnode, stacknode_1)
        stacknode = get_stacknode(new_active_parsers, state)
        if stacknode then
          stacknode.unshift(link)
        else
          stacknode = StackNode.new(state, [link])
          new_active_parsers.unshift(stacknode)
        end
      end
      return new_active_parsers
    end


    def get_rulenode(rule, treenodes)
      rulenode = @generated_rulenodes.detect do |r|
        r.rule == rule && (treenodes == r.elements)
      end
      unless rulenode then
        rulenode = RuleNode.new(rule, treenodes, cover(treenodes))
        @generated_rulenodes.unshift(rulenode)
      end
      return rulenode
    end

    def cover(treenodes)
      start = nil
      stop = nil
      f = nil
      treenodes.each do |treenode|
        f = treenode.cover
        if f then
          if start then
            stop = f[1..-1] # cdr       
          else
            start = f.first
            stop = f[1..-1]
          end
        end
      end
      if start then
        return [start] + stop
      else
        return nil
      end
    end


    def get_symbolnode(symbol, rulenode)
      symbolnode = @generated_symbolnodes.detect do |n|
        symbol == n.symbol and rulenode.cover == n.cover
      end
      if symbolnode then
        add_rulenode(symbolnode, rulenode)
      else
        symbolnode = SymbolNode.new(symbol, [rulenode], rulenode.cover)
        @generated_symbolnodes.unshift(symbolnode)
      end
      return symbolnode
    end


    def add_rulenode(symbolnode, rulenode)
      unless symbolnode.possibilities.include?(rulenode) then
        symbolnode.possibilities.unshift(rulenode)
      end
    end

    def get_stacknode(stacknodes, state)
      stacknodes.detect do |sn|
        sn.state == state
      end
    end
  end



end
