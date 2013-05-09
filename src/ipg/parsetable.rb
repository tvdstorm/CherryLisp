
require 'set'

module ParseTable

  class Modification
    attr_reader :grammar, :rule

    def initialize(parsetable, grammar, rule)
      @parsetable = parsetable
      @grammar = grammar
      @rule = rule
    end

    def do_it
      _do_it
      parse_table.taint_itemsets(rule.symbol)
    end

    def undo_it
      revert.do_it
    end

  end

  class AddRule < Modification
    private
    def _do_it
      parse_table.add_rule(grammar, rule)
    end

    def revert
      RemoveRule.new(parsetable, grammar, rule)
    end

  end

  class RemoveRule < Modification
    private
    def _do_it
      parse_table.remove_rule(grammar, rule)
    end

    def revert
      AddRule.new(parsetable, grammar, rule)
    end
  end

  class ParseTable
    attr_reader :itemsets, :rules, :start_state

    def initialize
      @rules = {}
      rule = Rule.new(:start, the_start_symbol, [a_start_symbol])
      item = Item.new(rule, 0)
      @start_state = ItemSet.new(kernel, self)
      @itemsets = Set.new([start_state])
    end

    def a_start_symbol
      :A_START
    end

    def is_the_start?(symbol)
      symbol == the_start_symbol
    end

    def the_start_symbol
      :THE_START
    end

    def add_rule(grammar, rule)
      symbol = rule.result
      if !rules.has_key?(symbol) then
        rules[symbol] = []
      end
      new_rule = rules[symbol].detect do |existing|
        existing.rule == rule
      end
      if !new_rule then
        new_rule = rule
      end
      new_rule.enable(grammar)
      rules[symbol] << new_rule
    end

    def remove_rule(grammar, rule)
      symbol = rule.result
      return if !rules.has_key?(symbol)
      old_rule = rules[symbol].detect do |existing|
        existing.rule == rule
      end
      return if !old_rule
      old_rule.disable(grammar)
      if old_rule.unused? then
        rules[symbol].delete(old_rule)
      end
    end

    def update_itemsets(symbol)
      itemsets.each do |itemset|
        if itemset.has_transition_on?(symbol) then
          itemsets.add(expand(itemset.kernel))
          itemsets.delete(itemset)
        end
      end
    end

    def k_closure(items)
      i = 0
      l = items.length
      closure = items.clone
      done = []
      while i < l do
        s = closure[i].next_symbol
        if s && !done.include?(s) then
          done.unshift(s)
          prods = rules[s] || []
          prods.each do |rule|
            item = Item.new(rule, 0)
            if not items.include?(item) then
              closure << item
              yield item
              l += 1
            end
          end
        end
        i += 1
      end
    end

    def expand(kernel)
      transitions = {}
      reductions = []
      f_acts = {}
      k_closure(kernel) do |item|
        s = item.nextsymbol
        if s then
          f_acts[s] ||= []
          f_acts[s] << item.move_dot
        else
          if is_the_start?(item.result) then
            transitions[:EOF] ||= []
            transitions[:EOF] << Accept.new
          else
            reductions.unshift(Reduce.new(item.rule))
          end
        end
      end
      f_acts.each_pair do |symbol, items|
        new_kernel = items.sort # !!!
        new_itemset = itemset_with_kernel(new_kernel)
        transitions[symbol] ||= []
        transitions[symbol] += [Shift.new(new_itemset)]
      end
      return ItemSet.new(kernel, transitions, reductions)
    end

    def itemset_with_kernel(kernel)
      itemset = itemsets.detect do |is|
        is.kernel == kernel
      end
      unless itemset then
        itemset = expand(kernel)
        #itemset = ItemSet.new(kernel, self)
        itemsets.add(itemset)
      end
      return itemset
    end
  end

end
