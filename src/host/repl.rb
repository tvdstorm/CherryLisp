
require 'readline'
require 'yaml'

# TOdo: Unescape braces

class SympREPL
  include Readline


  def add_symbol(sym)
    @completions << sym.to_s
  end

  def initialize(hist, symbols = [])
    hist.each do |elt|
      HISTORY.push(elt)
    end
    @completions = symbols.collect do |sym|
      sym.to_s
    end

    Readline.completer_word_break_characters = 7.chr
    Readline.completion_case_fold = true
    Readline.completion_proc = proc { |str|
	 if str == ""
	    @completions
	 else
	    exp = Regexp.new("^" + str)
	    @completions.find_all do |word|
	       word =~ exp
	    end
 	 end
    }
    reset
  end

  def history
    HISTORY.collect { |h| h }
  end

  def gets
    reset

    unless read_a_line?
      return nil
    end

    while nested? do
      unless read_a_line?
        return text
      end
    end
    
    return text
  end

  private

  def read_a_line?
    s = readline(prompt, false)
    return false if not s
    add_to_history(s)
    nest(s)
    unnest(s)
    add_line(s)
    return true
  end

  def reset
    @text = nil
    @level = 0
  end

  def add_line(s)
    @text = '' unless @text
    @text += s + "\n"
  end

  def text
    return nil unless @text
    return @text.chomp
  end

  def prompt
    prefix = ''
    prefix = "#{@level}" if @level > 0
    return prefix + '> '
  end

  def nest(s)
    m = s.scan(/[({\[]/)
    @level += m.length
  end

  def unnest(s)
    m = s.scan(/[)}\]]/)
    @level -= m.length
  end

  def nested?
    @level > 0
  end

  def add_to_history(s)
    HISTORY.push(s) if !s.empty?
  end
  
end
