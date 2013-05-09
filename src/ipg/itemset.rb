
class ItemSet 
  attr_reader :transitions, :reductions
  
  def initialize(kernel, parsetable)
    @kernel = kernel
    @parsetable = parsetable
    @reductions = {}
    @transitions = []
    @up_to_date = false
  end

  def actions(symbol)
    return reductions + transitions_on(symbol)
  end

  def goto(symbol)
    actions = transitions_on(symbol)
    raise "Goto returns multiple states" if actions.length > 1
    return actions.first.state
  end
    
  def transitions_on(symbol)
    transitions[symbol]
  end

  def has_transition_on?(symbol)
    transitions.has_key?(symbol)
  end

  def enabled?(mod)
    kernel.detect do |item| 
      item.enabled?(mod)
    end
  end

  def taint(symbol)
    if has_transition_on?(symbol) then
      @up_to_date = false
    end
  end

  def update
    @parsetable.expand(@transitions, @reductions)
    @up_to_date = true
  end

  def hash
    # !!! (sorting, see below)
    item = kernel.first
    return item.hash
  end


end
