

class Item
  include Comparable

  attr_reader :rule, :dot

  def initialize(rule, dot = 0) 
    @rule = rule
    @dot = dot
  end

  def result
    rule.result
  end

  def enabled?(mod)
    rule.enabled?(mod)
  end

  def move_dot
    return Item.new(rule, dot + 1)
  end

  def <=>(o)
    return object_id <=> o.object_id if dot == o.dot
    return dot <=> o.dot
  end

  def to_s
    "#{rule}:#{dot}"
  end

  def ==(o)
    o.rule == rule && o.dot == dot
  end

  def hash
    return rule.hash * (1 + dot)
  end

  def next_symbol
    return rule.elements[dot]
  end
end
