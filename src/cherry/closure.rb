
require 'cherry/pair'

class Procedure
  ANONYMOUS = '<anonymous>'
  attr_accessor :name

  def initialize
    @name = ANONYMOUS
  end

  def to_s
    return "{#{name}}"
  end

  def anonymous? 
    name == ANONYMOUS
  end
end

class Closure < Procedure
  attr_accessor :params, :body, :env

  def initialize(params, body, env)
    @params = params
    @env = env
    @body = body.is_a?(Pair) && body.rest == nil ? body.first : Pair.new(:begin, body)
  end
  
  def apply(interpreter, args)
    #puts "Params = #{params.prin}, args: #{args.prin}"
    #puts "Body: #{body.prin}"
    interpreter.eval(body, Environment.new(params, args, env))
  end
end

class Macro < Closure 

  def initialize(params, body, env) 
    super(params, body, env)
  end

  def expand(interpreter, old_pair, args) 
    expansion = apply(interpreter, args)
    #puts "Expansion: #{expansion.prin}"
    if expansion.is_a?(Pair) then
      old_pair.first = expansion.first
      old_pair.rest = expansion.rest
    else
      old_pair.first = :begin
      old_pair.rest = Pair.new(expansion, nil)
    end
    return old_pair
  end

  def Macro.expand(interpreter, x) 
    return x if !x.is_a?(Pair)
    fun = interpreter.eval(x.first, interpreter.global_environment)
    return fun if !fun.is_a?(Macro)
    return fun.expand(interpreter, x, x.rest)
  end

end
