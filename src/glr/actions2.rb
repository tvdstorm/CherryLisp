
class Action 

  # maybe do caching of enabled? here
  def react(parser, glr, grammar)
    if enabled?(grammar.name) then
      _react(parser, glr) # (next-method)
    end
  end

end

class Shift < Action
  attr_reader :state

  def initialize(state)
    @state = state
  end

  def _react(parser, glr)
    glr.schedule_for_shifter(parser, state)
  end

  def enabled?(mod)
    state.enabled?(mod)
  end

  def to_s
    return "shift(#{state})"
  end

  def ==(o)
    state == o.state
  end

  def eql?(o)
    state.eql?(o.state)
  end

  def hash
    return "shift#{state.hash}".hash
  end

end

class Reduce < Action
  attr_reader :rule
  def initialize(rule)
    @rule = rule
  end

  def enabled?(mod)
    rule.enabled?(mod)
  end

  def _react(parser, glr)
    glr.do_reductions(parser, [], rule.length, rule)
  end
 
  def to_s
    return "reduce(#{rule})"
  end
  
  def hash
    return "reduce#{rule.hash}".hash
  end

  def ==(o)
    rule == o.rule
  end

  def eql?(o)
    rule.eql?(o.rule)
  end

end

class Accept < Action
  def to_s
    return "accept"
  end

  def _react(parser, glr)
    # TODO: Check start symbol used in glr
    # otherwise don't do anything
    glr.set_result(parser)
  end

  def enabled?(mod)
    true
  end

  def ==(o)
    o.is_a?(Accept)
  end

  def eql?(o)
    self == o
  end

  def hash
    "accept".hash
  end

end
