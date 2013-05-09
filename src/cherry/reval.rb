
class ReadtimeCherry < Cherry

  def initialize(grammar)
    super()
    @grammar = grammar
  end

  def eval(x, env) 
    loop do
      if x.is_a?(Symbol) then
        return env.lookup(x)
      elsif !x.is_a?(Pair) then
        return x
      else 
        fun = x.first
        args = x.rest
        case fun
          # Here starts the read-time customization
        when :rule
          add_rule_to_grammar(args)
          return nil
        when :restrict
          add_restriction_to_grammar(args)
          return nil
          # And here it ends...
        when :quote 
          return args.first
        when :begin 
          while args.rest != nil do
            eval(args.first, env)
            args = args.rest
          end
          x = first(args);
        when :define 
          if args.first.is_a?(Pair) then
            return env.define(args.first.first,
                              eval(Pair.new(:lambda, Pair.new(args.first.rest, 
                                                      arg.rest)), env))
          end
        when :set! 
          return env.set(args.first, args.second, env)
        when :if 
          x = (eval(args.first, env) != false) ? args.second : args.third
        when :lambda
          return Closure.new(args.first, args.rest, env)
        when :macro 
          return Macro.new(args.first, args.rest, env)
        else # a call
          fun = eval(fun, env)
          if fun.is_a?(Macro) then
            x = fun.expand(self, x, args)
          elsif fun.is_a?(Closure) then
            x = fun.body
            env = Environment.new(fun.params, eval_list(args, env), fun.env)
          else
            return fun.apply(self, eval_list(args, env))
          end
        end
      end
    end
  end
end
