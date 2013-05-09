
class Node
  attr_accessor :cover, :id
  def initialize
    @id = nil
  end
  
  def <=>(o)
    id <=> o.id
  end

  def cover_str
    if not cover then
      return ""
    else
      return cover.join(', ')
    end
  end

  def order
    id_counter = 0
    @id = (id_counter += 1)
    seen = [self]
    to_process = [self]
    while not to_process.empty? do
      node = to_process.shift
      if node.is_a?(SymbolNode) then
        node.possibilities.each do |rulenode|
          unless seen.include?(rulenode) then
            rulenode.id = (id_counter += 1)
            seen.unshift(rulenode)
          end
          rulenode.elements.each do |el|
            if el then
              unless seen.include?(el) then
                el.id = (id_counter += 1)
                seen.unshift(el)
                to_process.unshift(el)
              end              
            end
          end
        end
      end
    end
    return seen.sort
  end

  def show_tree
    puts "result: #{prin}"
    order.each do |node|
      puts node.show
    end
  end

end

class RuleNode < Node
  attr_accessor :rule, :elements, :result
  def initialize(rule, elements, cover)
    super()
    @rule = rule
    @elements = elements
    @cover = cover
    @result = nil
  end

  def ambiguous?
    return elements.detect do |elt|
      elt.ambiguous?
    end
  end

  def accept_visitor(visitor)
    visitor.visit_rule_node(self)
  end
  
  def to_s
    return "rulenode(#{rule}, <#{cover_str}>)"
  end

  def prin
    return "R#{id}"
  end

  def show
    "#{prin}: #{rule} #{elements.collect {|x| x.prin }.join(', ')}"
  end

end

class SymbolNode < Node
  attr_accessor :symbol, :possibilities
  def initialize(symbol, possibilities, cover)
    super()
    @symbol = symbol
    @possibilities = possibilities
    @cover = cover
  end

  def accept_visitor(visitor)
    visitor.visit_symbol_node(self)
  end

  def ambiguous?
    possibilities.length > 1
  end
  
  def to_s
    return "symbolnode(#{symbol}, [#{possibilities.join(', ')}], <#{cover_str}>)"
  end

  def prin
    return "S#{id}"
  end

  def show
    "#{prin}: #{symbol} #{possibilities.collect {|x| x.prin }.join(', ')}"
  end

end

class TermNode < Node
  attr_accessor :token, :string
  def initialize(token, string, cover)
    super()
    @token = token
    @string = string
    @cover = cover
  end

  def accept_visitor(visitor)
    visitor.visit_term_node(self)
  end

  def ambiguous?
    false
  end

  def symbol
    return token
  end

  def to_s
    return "termnode(\"#{string}\", #{token}, <#{cover.join(', ')}>)"
  end

  def prin
    return "T#{id}"
  end

  def show
    "#{prin}: #{token} #{string}"
  end

end


