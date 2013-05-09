
module SExp

  class Cons
    attr_reader :head, :tail

    def self.from_array(array)
      return nil if array.empty?
      Cons.new(array.first, from_array(array[1..-1]))
    end

    def initialize(head, tail = nil)
      @head = head
      @tail = tail
    end
    
    def to_a
      a = [head]
      a += tail.to_a if tail
      return a
    end

    def to_s
      return "(#{quote_strings(to_a).join(' ')})"
    end

    def inspect
      to_s
    end

    private 
    def quote_strings(list)
      list.collect do |x|
        if x.is_a?(String)
          "\"#{x.gsub('"', '\\"')}\""
        else
          x
        end
      end
    end

  end

  class CollapseASTVisitor
    attr_reader :sexp

    def initialize(ast)
      @sexp = ast.accept_visitor(self)
    end

    def visit_appl_node(appl)
      args = appl.args
      func = appl.func
      case func
      when :top
        return collapse_stats(args[0])
      when :list
        return collapse_arg(args, 0)
      when :id
        return collapse_arg(args, 0).intern
      when :int
        return Integer(collapse_arg(args, 0))
      when :str
        return unquote(String(collapse_arg(args, 0)))
      else
        return Cons.new(func, array_to_sexp(args))
      end
    end
    
    def visit_list_node(list)
      list_to_sexp(list)
    end

    def visit_str_node(str)
      return str.str
    end

    def visit_amb_node(amb)
      raise "Visiting of amb nodes not implemented!"
    end

    private


    def array_to_sexp(array)
      Cons.from_array(collapse_array(array))
    end

    def list_to_sexp(list)
      array_to_sexp(list.elements)
    end

    def collapse_arg(args, i)
      args[i].accept_visitor(self)
    end

    def collapse_stats(stats)
      stats.elements.collect do |stat|
        case stat.func
        when :toplevel_syntax_extension, :let_syntax_statement 
          nil
        when :scoped_syntax_statement, :syntax_ref_statement
          collapse_stats(stat.args[1])
        when :sexp_stat
          collapse_arg(stat.args, 0)
        end
      end.compact.flatten
    end
    
    def collapse_array(array)
      list = array.collect do |elt|
        elt.accept_visitor(self)
      end.compact
    end

    def unquote(str)
      str[1..-2].gsub('\\"', '"')
    end
    
  end
end
