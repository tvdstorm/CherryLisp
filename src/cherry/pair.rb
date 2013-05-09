
class String
  def prin
    inspect
  end
end

class Object
  def prin
    to_s
  end
end

class Symbol
  def prin
    to_s
  end
end

class NilClass
  def prin
    '()'
  end
end

class FalseClass
  def prin
    "#f"
  end
end

class TrueClass
  def prin
    "#t"
  end
end

class Pair
  attr_accessor :first, :rest

  def initialize(first, rest)
    @first = first
    @rest = rest
  end

  def second
    return nil if rest.nil?
    rest.first
  end

  def third
    rest.rest.first
  end

  def fourth
    rest.rest.rest.first
  end

  def list?
    return true if rest.nil?
    return rest.is_a?(Pair) && rest.list?
  end

  def [](i)
    return first if i == 0
    return second if i == 1 && !list?
    return rest[i-1]
  end

  def length
    return 1 if rest.nil?
    return 2 if !list?
    return 1 + rest.length
  end

  def to_a
    result = []
    0.upto(length - 1) do |i|
      result << self[i]
    end
    return result
  end

  def inspect
    return "(#{first.inspect} . #{rest.inspect})"
  end

  def to_s
    to_a.join(' ')
  end

  def prin 
    s = "("
    if list? then
      l = length - 1
      0.upto(l) do |i|     
        s += self[i].prin
        s += " " if i < l
      end
    else
      if first.is_a?(Pair) then
        0.upto(first.length - 1) do |i|
          s += first[i].prin + ' '
        end
      else
        s += first.prin + ' '
      end
      s += ". #{rest.prin}"
    end
    s += ")"
    return s
  end
end
