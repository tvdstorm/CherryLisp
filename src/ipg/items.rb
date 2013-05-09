require 'ipg/rules'

class Item
  attr_reader :rule, :dot

  def initialize(rule, dot = 0) 
    @rule = rule
    @dot = dot
  end

  def result
    rule.result
  end

  def selected?
    rule.selected?
  end

  def enabled?(mod)
    rule.enabled?(mod)
  end

  def move_dot
    return Item.new(rule, dot + 1)
  end

  def <=>(o)
    if dot == o.dot then
      rule.id <=> o.rule.id
    else
      dot <=> o.dot
    end
  end

  def to_s
    io = StringIO.new
    io << "<#{rule.result} ::= "
    rule.elements.each_index do |i|
      if i == dot then
        io << "."
      else
        io << " "
      end
      io << rule.elements[i].to_s
    end       
    if dot == rule.elements.length then
      io << '.'
    end
    io << ">"
    return io.string
  end

  def ==(o)
    o.rule == rule && o.dot == dot
  end

  def eql?(o)
    return self == o && rule.id == o.rule.id
  end

  def hash
    return rule.id * (1 + dot)
  end

  def nextsymbol
    return rule.elements[dot]
  end
end


