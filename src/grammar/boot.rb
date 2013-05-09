
require 'ipg/rules'
require 'ipg/grammar'
require 'ipg/normalizer'
require 'grammar/charclass'

=begin
start START
restrict Int: [0-9]
cf start START ::= Id ":=" Exp
cf plus Exp ::= Exp "+" Exp
cf mult Exp ::= Exp "*" Exp
cf int Exp ::= Int
lex digit Int ::= Digit
lex digits Int ::= Digit Digits
lex digit Digit ::= [0-9]

Allowed in righthandside of rules:
- a list of symbols consisting of sorts and literals separated by single space
- a single character class
Sorts must be longer than one character!

=end


module BootstrapGrammar

  class ReaderState
    attr_reader :rules, :restrictions
    attr_accessor :start_symbol

    def self.new
      if block_given? then
        state = ReaderState.new
        yield state
        return state
      end
      super()
    end

    def initialize
      @rules = []
      @restrictions = {}
      @restrictions.default = []
      @start_symbol = nil
    end

    def grammar
      g = Grammar.new(@start_symbol, @restrictions)
      g.add_rules(normalize_rules(@rules))
      return g
    end

    def normalize
      normalize_rules(@rules)
    end

    private
    
    def normalize_rules(rules)
      rules.inject([]) do |result, rule|
        result | Normalizer.new(rule).normalize
      end
    end
  end

  class Reader

    def self.from_file(filename)
      self.new(File.read(filename))
    end

    def initialize(stream)
      @stream = stream
    end

    def grammar
      parse.grammar
    end

    def normalize
      parse.normalize
    end


    private

    def parse
      ReaderState.new do |state|
        read(state)
      end
    end

    def read(state)
      @stream.each_line do |line|    
        read_line(state, line)
      end
    end

    def read_line(state, line)
      if line =~ /^#/ then
        return
      elsif line =~ /^$/ then
        return
      elsif line =~ /^(cf|lex) ([a-z\-_]+) (\<?[A-Z][a-zA-Z_]+\>?) ::= (.*)$/ then
        type = $1
        label = $2.intern
        result = $3.intern
        symbols = $4.split(' ').collect do |str|
          str.intern
        end
        if $1 == 'cf' then
          state.rules << CFRule.new(label, result, symbols)
        else
          state.rules << LexRule.new(label, result, symbols)
        end
      elsif line =~ /^start (\<?[A-Z][a-zA-Z_]+\>?)$/ then
        # a start symbol
        state.start_symbol = $1.intern
      elsif line =~ /^restrict (\<?[A-Z][a-zA-Z_]+\>?): (.*)$/
        # a restriction
        sort = $1.intern
        ranges = CharClass.match($2)
        set = []
        ranges.each do |range|
          range.each do |char|
            set |= [char]
          end
        end
        state.restrictions[sort] = set
      else
        raise "Could not parse production: #{line}"
      end
    end
  end
end
