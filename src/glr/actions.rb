
class Action 
  def reduce_again(parser, link, glr)
  end
end

class Shift < Action
  attr_reader :state

  def initialize(state)
    @state = state
  end


  def react(parser, glr)
    glr.schedule_for_shifter(parser, state)
  end

  def selected?
    state.kernel.detect do |item| 
      item.selected?  
    end
  end

  def to_s
    return "shift(#{state})"
  end

  def ==(o)
    o.state == state
  end

  def eql?(o)
    o.state.eql?(state)
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

  def selected?
    rule.selected?
  end

  def react(parser, glr)
   glr.do_reductions(parser, [], rule.length, rule)
  end
 
  def reduce_again(parser, link, glr)
    glr.do_reductions(parser, [], rule.length, rule, link, false)
  end

  def to_s
    return "reduce(#{rule})"
  end
  
  def hash
    return "reduce#{rule.hash}".hash
  end

  def ==(o)
    o.rule == rule
  end

  def eql?(o)
    o.rule.eql?(rule)
  end

end

class Accept < Action
  def to_s
    return "accept"
  end

  def react(parser, glr)
    # TODO: Check start symbol used in glr
    # otherwise don't do anything
    glr.set_result(parser)
  end

  def selected?
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
