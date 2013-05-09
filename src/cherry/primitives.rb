
require 'cherry/pair'
require 'cherry/closure'

module Primitives
  # Methods in this module will automatically be primitives

  def Primitives.primitives
    self.public_instance_methods.collect do |name|
      name.to_sym
    end
  end

  def plus(x, *y)
    return y.inject(x) do |total, x|
      total += x
    end
  end

  def min(x, y)
    x - y
  end

  def times(x, *y)
    return y.inject(x) do |total, x|
      total *= x
    end
  end

  def to_string(x)
    return x.to_s
  end

  def to_symbol(x)
    return x.to_sym
  end

  def equalp(x, y)
    x == y
  end

  def leq(x, y)
    x <= y
  end

  def geq(x, y)
    x >= y
  end

  def lt(x, y)
    x < y
  end

  def gt(x, y)
    x > y
  end

  def first(x)
    x.first
  end

  def rest(x)
    if x.is_a?(Pair) then
      x.rest
    else
      raise "Rest on: #{x}"
    end
  end

  def car(x)
    x.first
  end

  def cdr(x)
    x.rest
  end

  def not(x)
    x == false
  end

  def nullp(x)
    x == nil
  end

#   def and(*args)
#     args.inject(true) do |cur,x|
#       cur && x
#     end
#   end
  
#   def or(*args)
#     args.inject(false) do |cur,x|
#       cur || x
#     end
#   end

  def amb(*args)
    args = args.collect do |x|
      x.prin
    end
    raise "Ambiguity: #{args.join(', ')}"
  end

  def booleanp(x)
    x == true || x == false
  end

  def symbolp(x)
    x.is_a?(Symbol)
  end
  
  def vectorp(x)
    false
  end
  
  def eqp(x, y)
    equalp(x, y)
  end

  def eqvp(x, y)
    equalp(x, y)
  end

  def pairp(x)
    x.is_a?(Pair)
  end

  def listp(x)
    pair?(x) && x.list?
  end
  
  def cons(x, y)
    Pair.new(x, y)
  end

  def set_first(x, y)
    x.first = y
  end

  def set_rest(x, y)
    x.rest = y
  end

  def second(x)
    x.second
  end

  def third(x)
    x.third
  end

  def fourth(x)
    x.fourth
  end

  def length(x)
    x.length
  end

  def append(*args)
    result = []
    args.each do |x|
      result += x.to_a
    end
    return list(*result)
  end

  def readfile(filename)
    return File.read(filename)
  end

  def load(filename)
    eval(parse(readfile(filename)))
  end

  def eval(x)
    interpreter.eval(x)
  end

  def eval_when_read(x)
    interpreter.eval(x)
  end

  def eval_string(x)
    #puts parse(x).prin
    eval(parse(x))
  end

  # TODO: should be in prelude via "grammar"
  def parse(x)
    grammar = interpreter.parser.grammar
    parse_with(grammar, x)
  end

  def print(*args)
    puts args.collect { |x| x.to_s }.join(' ')
  end


  def parse_with(grammar, str)
    # small optimization
    parser = interpreter.parser
    str = str.strip
    if grammar === parser.grammar then
      pt = parser.parse(str)
    else
      pt = parse.parse_with_grammar(grammar, str)
    end
    #p CherryImploder.new(pt).ast
    return  CherryImploder.new(pt).ast
  end

  def str2sym(str)
    return str.to_sym
  end

  def str2int(str)
    return Integer(str)
  end

  def macroexpand(form)
    Macro.expand(interpreter, form)
  end

  def list(*args)
    result = nil
    args.reverse.each do |x|
      result = cons(x, result)
    end
    return result
  end

  def map(proc, *rest)
    __map(proc, list(*rest), interpreter, list(nil))
  end


  private

  def __map(proc, args, interp, result)
    accum = result
    if args.rest.nil? then
      args = args.first
      while args.is_a?(Pair) do
        x = proc.apply(interp, list(args.first))
        if !accum.nil? then
          accum = (accum.rest = list(x)) # check!
        end
        args = args.rest
      end
    else
      car = interp.eval(:car)
      cdr = interp.eval(:cdr)
      while args.first.is_a?(Pair) do
        x = proc.apply(interp, __map(car, list(args), interp, list(nil)))
        if !accum.nil then
          accum = (accum.rest = list(x)) #check!
        end
        args = __map(cdr, list(args), interp, list(nil))
      end
    end
    return result.rest
  end


end



if __FILE__ == $0 then
  p Primitives.instance_methods
end
