
class Rule
  include Comparable

  attr_reader :elements, :result, :label

  def initialize(label, result, elements)
    @label = label
    @result = result
    @elements = elements
    @mods = []
  end

  def self.make(label, result, symbols, layout = nil)
    if layout then
      return LayoutRule.new(label, result, symbols, layout)
    end
    return Rule.new(label, result, symbols)
  end

  def enabled?(mod)
    @mods.include?(mod)
  end

  def enable(mod)
    @mods |= [mod]
  end
  
  def disable(mod)
    @mods.delete(mod)
  end
  
  def unused?
    @mods.empty?
  end

  def has_layout?
    false
  end
  
  def length
    return elements.length
  end
  
  def ==(o)
    o.elements == elements &&
      o.result == result &&
      o.label == label
  end

  def to_s
    return "#{label} #{result} ::= '#{elements.join(' ')}'"
  end

  def hash
    return to_s.hash
  end

end

class LayoutRule < Rule
  attr_reader :layout

  def initialize(label, result, elements, layout)
    super(label, result, intersperse(elements, layout))
    @layout = layout
  end

  def has_layout?
    true
  end

  private 

  def intersperse(elements, layout)
    new_elements = []
    0.upto(elements.length - 1) do |i|
      new_elements << elements[i]
      if i < elements.length - 1 then
        new_elements << layout
      end
    end
    return new_elements
  end

end
