
require 'grammar/charclass'

class Production
  attr_reader :label, :result, :symbols
  
  CF = 'cf'
  LEX = 'lex'

  def initialize(label, result, symbols)
    @label = label
    @result = result
    @symbols = symbols
  end

  def self.make(type, label, result, symbols)
    if type == CF then
      return CFProduction.new(label, result, symbols)
    elsif type == LEX then
      return LexProduction.new(label, result, symbols)
    else
      raise "Invalid production type: #{type}"
    end
  end


=begin
  def add_lexicals(table = {})
    @symbols.each do |sym|
      if sym =~ /^"(([^"]|[\\]["])+)"$/ then # a literal
        str = $1.gsub('\"', '"')
        table[sym] = Regexp.new(Regexp.escape(str))
      elsif sym =~ /^\[((.-.)*)(.*)\][*+?]?$/ then # a charclass
        # since splitting on space, spaces in charclasses
        # are represented by \s
        re = Regexp.new(sym.gsub('\s', ' '))
        p re
        table[sym] = re
      else
        # ignore all other symbols
      end
    end
  end
=end

  def normalize
    added_rules = []
    @symbols.each do |sym|
      if sym =~ /^\<?[A-Z][a-zA-Z0-9_\-]*\>?$/ then # a sort
        # nop
      elsif sym =~ /^(\<?[A-Z][a-zA-Z0-9_\-]*\>?)\+$/ then # a sort +
        sort = $1
        added_rules << Production.make(type, :flatten, sym, [sort])
        added_rules << Production.make(type, :flatten, sym, [sort, sym])
      elsif sym =~ /^(\<?[A-Z][a-zA-Z0-9_\-]*\>?)\*$/ then # a sort *
        sort = $1
        added_rules << Production.make(type, :flatten, sym, [])
        added_rules << Production.make(type, :flatten, sym, [sort, sym])
      elsif sym =~ /^(\<?[A-Z][a-zA-Z0-9_\-]*\>?):"(([^"]|[\\]["])+)"\*$/ then # a sort sep *
        sort = $1
        sep_str = $2
        sep = sep_str.gsub('\"', '"')
        sep_lit = "\"#{sep_str}\""
        plus_sym = sym[0..sym.length-2] + "+"
        added_rules << LexProduction.new("lit", sep_lit, sep.split(''))
        # First add the plus variation
        added_rules << Production.make(type, :flatten, plus_sym, [sort])
        added_rules << Production.make(type, :flatten, plus_sym, [sort, sep_lit, plus_sym])
        # Then extend it for * variation
        added_rules << Production.make(type, :flatten, sym, [])
        added_rules << Production.make(type, :flatten, sym, [plus_sym])
      elsif sym =~ /^(\<?[A-Z][a-zA-Z0-9_\-]*\>?):"(([^"]|[\\]["])+)"\+$/ then # a sort sep +
        sort = $1
        sep_str = $2
        sep = sep_str.gsub('\"', '"')
        sep_lit = "\"#{sep_str}\""
        plus_sym = sym[0..sym.length-2] + "+"
        added_rules << LexProduction.new("lit", sep_lit, sep.split(''))
        added_rules << Production.make(type, :flatten, plus_sym, [sort])
        added_rules << Production.make(type, :flatten, plus_sym, [sort, sep_lit, plus_sym])
      elsif sym =~ /^\<?([A-Z][a-zA-Z0-9_\-]*\>?)\?$/ then # a sort ?
        sort = $1
        prod_label = "#{sort.downcase}-opt"
        added_rules << Production.make(type, prod_label, sym, [])
        added_rules << Production.make(type, prod_label, sym, [sort])
      elsif sym =~ /^"(([^"]|[\\]["])+)"$/ then # a literal
        # split $1 and replace literal in syms 
        lit = $1.gsub('\"', '"')
        # NB: identical literals will merge into same production (same label)
        added_rules << LexProduction.new("lit", sym, lit.split(''))
      else
        ranges = CharClass.match(sym)
        if ranges then
          ranges.each do |range|
            range.each do |char|
              #p range
              #p char
              added_rules << LexProduction.new("char", sym, [char])
            end
          end
        else
          raise "Invalid symbol: #{sym}"
        end
      end 
    end
    return added_rules
  end
  
  def inspect
    return "#{type} #{label} #{result} ::= <#{symbols.join(' ')}>"
  end
  
end

class CFProduction < Production
  def is_context_free?
    return true
  end

  def type
    Production::CF
  end

  def add(grammar)
    grammar.add_cf_rule(label, result, symbols)
  end

  def remove(grammar)
    grammar.remove_cf_rule(label, result, symbols)
  end

  def contained_in?(grammar)
    grammar.contains_cf_rule?(label, result, symbols)
  end

end

class LexProduction < Production
  def is_context_free?
    return false
  end

  def  add(grammar)
    grammar.add_lex_rule(label, result, symbols)
  end

  def remove(grammar)
    grammar.remove_lex_rule(label, result, symbols)
  end

  def type
    Production::LEX
  end

  def contained_in?(grammar)
    grammar.contains_lex_rule?(label, result, symbols)
  end

end
