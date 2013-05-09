
module AST

  module MatchUtils
    def match_var(var, env)
      if env[var] then
        return self == env[var]
      else
        env[var] = self
        return true
      end
    end

    def match_arrays(l1, l2, env)
      return false if l1.length != l2.length
      0.upto(l1.length - 1) do |i|
        return false if !l1[i].match(l2[i], env)
      end
      return true
    end

    def var?(term)
      return false unless term.is_a?(Symbol)
      term.to_s[-1].chr == '?'
    end
  end

  class Node
    include MatchUtils

    def inspect
      to_s
    end

    def hash
      to_s.hash
    end
    
    def eql?(o)
      self == o
    end
    
  end

  class Appl < Node
    attr_reader :func, :args
    
    def initialize(func, args)
      @func = func
      @args = args
    end

    def ==(o)
      return false unless o.is_a?(Appl)
      return func == o.func && args == o.args
    end
    
    def to_s
      "#{func}(#{args.join(', ')})"
    end

    def accept_visitor(visitor)
      visitor.visit_appl_node(self)
    end

    def match(term, env)
      return match_var(term, env) if var?(term)
      return false unless term.is_a?(Array)
      return false unless term[0] == func
      return false unless term[1].is_a?(Array)
      return match_arrays(args, term[1], env)
    end    

  end

  class List < Node
    include Enumerable

    attr_reader :elements

    def initialize(elements)
      @elements = elements
    end

    def ==(o)
      return false unless o.is_a?(List)
      return elements == o.elements
    end

    def to_s
      "[#{elements.join(', ')}]"
    end

    def length
      elements.length
    end

    def each(&block)
      elements.each(&block)
    end

    def match(term, env)
      return match_var(term, env) if var?(term)
      return false unless term.is_a?(List)
      return false unless length == term.length
      return match_arrays(elements, term.elements, env)
    end

    def accept_visitor(visitor)
      visitor.visit_list_node(self)
    end

  end

  class Str < Node
    attr_reader :str
    def initialize(str)
      @str = str
    end

    def ==(o)
      return false unless o.is_a?(Str)
      return str == o.str
    end
    
    def accept_visitor(visitor)
      visitor.visit_str_node(self)
    end

    def to_s
      return str
    end

    def match(term, env)
      return match_var(term, env) if var?(term)
      return false unless term.is_a?(Str)
      return self == term
    end

  end
  
  class Amb < Node
    attr_reader :alts

    def initialize(alts)
      @alts = alts
    end
   
    def ==(o)
      return false unless o.is_a?(Amb)
      return alts == o.alts
    end
 
    def to_s
      "{#{alts.join(', ')}}"
    end

    def match(term, env)
      raise "Matching amb nodes not supported!"
    end

    def accept_visitor(visitor)
      visitor.visit_amb_node(self)
    end

  end

end
