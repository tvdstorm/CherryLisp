
class Rule
  attr_reader :elements, :result, :label, :grammars
  attr_accessor :selected, :id

  CF = 'cf'
  LEX = 'lex'

  def initialize(label, result, elements, selected = true, id = nil)
    @label = label
    @result = result
    @elements = elements
    @selected = selected
    @id = id
    @grammars = []
  end

  def self.make(type, label, result, symbols)
    if type == CF then
      return CFRule.new(label, result, symbols)
    elsif type == LEX then
      return LexRule.new(label, result, symbols)
    else
      raise "Invalid production type: #{type}"
    end
  end

  def add_grammar(grammar)
    grammars |= [grammar]
  end
  
  def remove_grammar(grammar)
    grammars.delete(grammar)
  end
  
  def unused?
    grammars.empty?
  end
  
  def selected?
    return selected
  end

  def length
    return elements.length
  end
  
  def ==(o)
    o.elements == elements &&
      o.result == result &&
      o.label == label
  end

  def eql?(o)
    self == o
  end

  def to_s
    #return "#{label.inspect} #{result.inspect} ::= #{elements.collect {|x| x.inspect}.join(' ')}"
    return "#{label} #{result} ::= <<#{elements.join(' ')}>>"
  end

  def hash
    return (label.to_s + result.to_s + elements.to_s).hash
  end

  def lexical?
    false
  end

  def context_free?
    !lexical?
  end

end

class LexRule < Rule
  def lexical?
    true
  end

  def type
    Rule::LEX
  end


end

class CFRule < Rule

  def initialize(label, result, elements, selected = true, id = nil)
    super(label, result, intersperse_with_layout(elements), selected, id)
  end

  def type
    Rule::CF
  end

  private 
  def intersperse_with_layout(elements)
    new_elements = []
    0.upto(elements.length - 1) do |i|
      new_elements << elements[i]
      if i < elements.length - 1 then
        new_elements << :LAYOUT
      end
    end
    return new_elements
  end

end
