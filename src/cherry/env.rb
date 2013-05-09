
require 'cherry/primitives'
require 'cherry/closure'
require 'cherry/pair'

class Environment

  attr_accessor :vars, :vals, :parent

  def Environment.initial(interpreter, grammar)
    env = self.new
    env.install_primitives(interpreter)
    env.define(:grammar, grammar)
    return env
  end

  def initialize(vars = nil, vals = nil, parent = nil)
    if !number_of_args_ok?(vars, vals) then
      raise "wrong number of arguments: expected #{vars.prin}, got: #{vals.prin}"
    end
    @vars = vars
    @vals = vals
    @parent = parent
  end

  def install_primitives(interpreter)
    Primitives.primitives.each do |name|
      define(name, Primitive.new(name, interpreter))
    end
  end

  def lookup(symbol)
    vr = vars
    vl = vals
    #puts "For #{symbol}: VARS: #{vr.prin}; VALS: #{vl.prin}"
    while !vr.nil? do
      #puts "HEAD: #{vr.first.prin}" if vr.is_a?(Pair)
      if vr.is_a?(Pair) && vr.first == symbol then
        return vl.first
      elsif vr == symbol then
        return vl
      else
        vr = vr.is_a?(Pair) ? vr.rest : nil
        vl = vl.is_a?(Pair) ? vl.rest : nil
      end
    end
    return parent.lookup(symbol) if !parent.nil?
    raise "Unbound variable: #{symbol}"
  end

  def define(var, val) 
    @vars = Pair.new(var, vars)
    @vals = Pair.new(val, vals)
    if val.is_a?(Procedure) && val.anonymous? then
      val.name = var.to_s
    end
    return var
  end

  def setd(var, val)
    raise "Attempt to set non-symbol: #{var}" if !var.is_a?(Symbol)
    vr = vars
    vl = vals
    while !vr.nil? do
      if vr.first == var then
        vl.first = val
        return val
      elsif vr.rest == var then
        vl.rest = val
        return val
      else
        vr = vr.rest
        vl = vl.rest
      end
    end
    define(var, val)
  end

  def set(var, val) 
    raise "Attempt to set non-symbol: #{var}" if !var.is_a?(Symbol)
    vr = vars
    vl = vals
    while !vr.nil? do
      if vr.first == var then
        vl.first = val
        return val
      elsif vr.rest == var then
        vl.rest = val
        return val
      else
        vr = vr.rest
        vl = vl.rest
      end
    end
    return parent.set(var, val) if !parent.nil?
    raise "Unbound variable: #{var}"
  end

  private

  class Primitive < Procedure
    include Primitives
    attr_reader :interpreter

    # NOTE: any method here, interferes with Primitives!!!
    # cf. prin may not be a primitive!!!

    def initialize(name, interpreter)
      @name = name
      @interpreter = interpreter
    end
    
    def apply(interpreter, args)
      array = args.to_a
      s = name.to_s.gsub('-', '_')
      return self.send(name.to_sym, *args)
    end

    def prin
      to_s
    end
  end
  
  def number_of_args_ok?(vars, vals)
    return (vars == nil && vals == nil)  || vars.is_a?(Symbol) ||
      (vars.is_a?(Pair) && vals.is_a?(Pair) && number_of_args_ok?(vars.rest, vals.rest))
  end

end
