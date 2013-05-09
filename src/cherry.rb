

require 'glr/ext-glr'
require 'glr/lazy-glr'
require 'cherry/pt2sexp'
require 'cherry/primitives'
require 'grammar/boot'
require 'ipg/grammar'
require 'host/repl'
require 'cherry/eval'
require 'pp'

def repl(cherry)
  hist = []
  if File.exist?('.history') then
    hist = YAML.load_file('.history')    
  end
  prims = Primitives.primitives
  prims += [:define, :q, :if, :cond, :macro, :lambda, :set, :begin]
  repl = SympREPL.new(hist, prims)
  loop do
    line = repl.gets
    break unless line
    next if line.empty?
    # Save history immediately.
    File.open('.history', 'w') do |f|
      YAML.dump(repl.history, f)
    end
    begin
      result = cherry.eval_string(line.strip)
    rescue GLR::ParseError => detail
      puts detail.message
    rescue RuntimeError => detail
      puts detail.message
    else
        puts result.prin 
    end
  end
end


if __FILE__ == $0 then
  repl(Cherry.new)
end
