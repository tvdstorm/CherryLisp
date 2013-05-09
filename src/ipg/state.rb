
require 'pp'
require 'stringio'


require 'ipg/items'
require 'glr/actions'


class ItemSet # State
  attr_accessor :type, :kernel, :trans, :reductions, :sp_trans, :sp_reds, :id, :refcount, :grammar

  def initialize(type, kernel, id, refcount, grammar = nil)
    @type = type
    @kernel = kernel
    @id = id
    @refcount = refcount
    @grammar = grammar
    @trans = {}
    @trans.default = []
    @reductions = []
    @sp_trans = {}
    @sp_trans.default = []
    @sp_reds = []
  end

    
  def ==(o)
    return false unless o.is_a?(ItemSet)
    return o.kernel == kernel
  end

  def action(symbol)
    if type != :specialized  then
      if type != :complete then
        expand_itemset
      end
      restrict_state
    end
    return @sp_reds + @sp_trans[symbol] 
    #return reductions + trans[symbol]
  end

  def taint(symbol)
    if [:complete, :specialized].include?(@type) && trans.has_key?(symbol)
      #if type == :complete && trans.has_key?(symbol)
      @type = :dirty
    end
  end


  def goto(symbol)
    result = @sp_trans[symbol].collect do |action|
      #result = trans[symbol].collect do |action|
      action.state
    end
    raise "Goto returns multiple states" if result.length > 1
    return result[0]
  end

  def restrict_state
    #selection = grammar.current_selection
    #if selection != :all then
    ###
    _sp_trans = {}
    _sp_trans.default = []
    _sp_reds = @reductions.select do |reduction|
      reduction.selected?
    end
    @trans.each_pair do |symbol, actions|
      actions.each do |action|
        _sp_trans[symbol] += [action] if action.selected?
      end
    end
    @sp_reds = _sp_reds
    @sp_trans = _sp_trans
    @type = :specialized    
    #####
    #else
    #  @sp_reds = @reductions.clone
    #  @sp_trans = @trans.clone
    #  @type = :specialized
    #end
  end

  def expand_itemset
    if [:initial, :dirty].include?(type) then
      expand
    end
  end

  def expand
    f_acts = {}
    f_acts.default = []
    acts = {}
    acts.default = []
    reds = []
    k_closure(@kernel, @grammar).each do |item|
      s = item.nextsymbol
      if s then
        f_acts[s] += [item.move_dot]
      else
        if item.rule.result == grammar.start_symbol then
          acts[:EOF] += [Accept.new]
        else
          reds.unshift(Reduce.new(item.rule))
        end
      end
    end
    f_acts.each_pair do |symbol, items|
      new_kernel = items.sort
      new_itemset = @grammar.itemset_with_kernel(new_kernel)
      acts[symbol] += [Shift.new(new_itemset)]
    end
    @trans = acts
    @reductions = reds
    @type = :complete
  end


  def k_closure(items, grammar)
    i = 0
    l = items.length
    closure = items.clone
    rules = grammar.rules
    done = []
    while i < l do
      s = closure[i].nextsymbol
      if s && !done.include?(s) then
        done.unshift(s)
        prods = rules[s] || []
        prods.each do |rule|
          item = Item.new(rule, 0)
          if not items.include?(item) then
            closure << item
            l += 1 
          end
        end
      end
      i += 1
    end
    return closure  
  end

  def hash
    # That's why they have to be sorted (in kernel)!
    item = kernel.first
    return item.hash
  end

end

