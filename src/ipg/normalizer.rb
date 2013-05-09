
require 'ipg/rules'

class Normalizer

  def initialize(rule)
    @rule = rule
  end

  def elements
    @rule.elements
  end

  def type
    @rule.type
  end

  def normalize_plus(sym, sort)
    [Rule.make(type, :flatten, sym, [sort]),
     Rule.make(type, :flatten, sym, [sym, sort])]
  end

  def normalize_star(sym, sort)
    plus_sym = "#{sort}+".intern
    normalize_plus(plus_sym, sort) +
      [Rule.make(type, :flatten, sym, []),
       Rule.make(type, :flatten, sym, [plus_sym])]
  end

  def normalize_plus_sep(sym, sort, sep)
    normalize_literal(sep) +
      [Rule.make(type, :flatten, sym, [sort]),
       Rule.make(type, :flatten, sym, [sym, sep, sort])]
  end

  def normalize_star_sep(sym, sort, sep)
    plus_sym = "#{sort}:#{sep}+".intern
    normalize_plus_sep(plus_sym, sort, sep) +
      [Rule.make(type, :flatten, sym, []),
       Rule.make(type, :flatten, sym, [plus_sym])]
  end

  def normalize_literal(sym)
    lit_str = sym.to_s[1..-2].gsub('\"', '"')
    [LexRule.new(:lit, sym, lit_str.split(''))]
  end

  def normalize_ranges(sym, ranges)
    ranges.collect do |range|
      range.collect do |char|
        LexRule.new(:char, sym, [char])
      end
    end.flatten
  end

  def normalize
    elements.inject([@rule]) do |rules, sym|
      str = sym.to_s
      if str =~ /^\<?[A-Z][a-zA-Z0-9_\-]*\>?$/ then # a sort
        rules
      elsif str =~ /^(\<?[A-Z][a-zA-Z0-9_\-]*\>?)\+$/ then # a sort +
        rules | normalize_plus(sym, $1.intern)
      elsif str =~ /^(\<?[A-Z][a-zA-Z0-9_\-]*\>?)\*$/ then # a sort *
        rules | normalize_star(sym, $1.intern)
      elsif str =~ /^(\<?[A-Z][a-zA-Z0-9_\-]*\>?):"(([^"]|[\\]["])+)"\*$/ then # a sort sep *
        rules | normalize_star_sep(sym, $1.intern, "\"#{$2}\"".intern)
      elsif str =~ /^(\<?[A-Z][a-zA-Z0-9_\-]*\>?):"(([^"]|[\\]["])+)"\+$/ then # a sort sep +
        rules | normalize_plus_sep(sym, $1.intern, "\"#{$2}\"".intern)
      elsif str =~ /^"(([^"]|[\\]["])+)"$/ then # a literal
        rules | normalize_literal(sym)
      else
        ranges = CharClass.match(str)
        if ranges then
          rules | normalize_ranges(sym, ranges)
        else
          raise "Invalid symbol: #{sym.inspect}"
        end
      end 
    end
  end


end
