

class Primitive

  EQ = 0
  LT = 1
  GT = 2
  GE = 3
  LE = 4

  ABS = 5
  EOF_OBJECT = 6
  EQQ = 7
  EQUALQ = 8
  FORCE = 9

  CAR = 10
  FLOOR = 11
  CEILING = 12
  CONS = 13
  
  DIVIDE= 14
  LENGTH = 15
  LIST = 16
  LISTQ = 17
  APPLY = 18

  MAX = 19
  MIN = 20
  MINUS = 21
  NEWLINE = 22
  
  NOT = 23
  NULLQ = 24
  NUMBERQ = 25
  PAIRQ = 26
  PLUS = 27
  
  PROCEDUREQ = 28
  READ = 29
  CDR = 30
  ROUND = 31
  SECOND = 32
  
  SYMBOLQ = 33
  TIMES = 34
  TRUNCATE = 35
  WRITE = 36
  APPEND = 37

  BOOLEANQ = 38
  SQRT = 39
  EXPT = 40
  REVERSE = 41
  ASSOC = 42
  
  ASSQ = 43
  ASSV = 44
  MEMBER = 45
  MEMQ = 46
  MEMV = 47
  EQVQ = 48

  LISTREF = 49
  LISTTAIL = 50
  STRINQ = 51
  MAKESTRING = 52
  STRING = 53

  STRINGLENGTH = 54
  STRINGREF = 55
  STRINGSET = 56
  SUBSTRING = 57
  
  STRINGAPPEND = 58
  STRINGTOLIST = 59
  LISTTOSTRING = 60
  
  SYMBOLTOSTRING = 61
  STRINGTOSYMBOL = 62
  EXP = 63
  LOG = 64
  SIN = 65

  COS = 66
  TAN = 67
  ACOS = 68
  ASIN = 69
  ATAN = 70
  
  NUMBERTOSTRING = 71
  STRINGTONUMBER = 72
  CHARQ = 73

  CHARALPHABETICQ = 74
  CHARNUMERICQ = 75
  CHARWHITESPACEQ = 76

  CHARUPPERCASEQ = 77
  CHARLOWERCASEQ = 78
  CHARTOINTEGER = 79

  INTEGERTOCHAR = 80
  CHARUPCASE = 81
  CHARDOWNCASE = 82
  STRINGQ = 83

  VECTORQ = 84
  MAKEVECTOR = 85
  VECTOR = 86
  VECTORLENGTH = 87

  VECTORREF = 88
  VECTORSET = 89
  LISTTOVECTOR = 90
  MAP = 91
  
  FOREACH = 92
  CALLCC = 93
  VECTORTOLIST = 94
  LOAD = 95
  DISPLAY = 96

  INPUTPORTQ = 98
  CURRENTINPUTPORT = 99
  OPENINPUTFILE = 100
  
  CLOSEINPUTPORT = 101
  OUTPUTPORTQ = 103
  CURRENTOUTPUTPORT = 104

  OPENOUTPUTFILE = 105
  CLOSEOUTPUTPORT = 106
  READCHAR = 107

  PEEKCHAR = 108
  EVAL = 109
  QUOTIENT = 110
  REMAINDER = 111

  MODULO = 112
  THIRD = 113
  EOFOBJECTQ = 114
  GCD = 115
  LCM = 116
  
  CXR = 117
  ODDQ = 118
  EVENQ = 119
  ZEROQ = 120
  POSITIVEQ = 121

  NEGATIVEQ = 122
  
  CHARCMP = 123 # to 127 
  CHARCICMP = 128 # to 132 

  STRINGCMP = 133 # to 137
  STRINGCICMP = 138 # to 142

  EXACTQ = 143
  INEXACTQ = 144
  INTEGERQ = 145

  CALLWITHINPUTFILE = 146
  CALLWITHOUTPUTFILE = 147


  attr_reader :min_args, :max_args

  def initialize(id_number, min_args, max_args)
    @id_number = id_number
    @min_args = min_args
    @max_args = max_args
  end

  def Primitive.install_primitives(env)
    n = 2 ** 29
    env.def_primitive(:"*",       TIMES,     0, n)
    env.def_primitive(:"+",       PLUS,      0, n)
    env.def_primitive(:"-",       MINUS,     1, n)
    env.def_primitive(:"/",       DIVIDE,    1, n)
    env.def_primitive(:"<",       LT,        2, n)
    env.def_primitive(:"<=",      LE,        2, n)
    env.def_primitive(:"=",       EQ,        2, n)
    env.def_primitive(:">",       GT,        2, n)
    env.def_primitive(:">=",      GE,        2, n)
    env.def_primitive(:"append",         APPEND,    0, n)
    env.def_primitive(:"apply",   APPLY,     2, n)
    env.def_primitive(:"assoc",   ASSOC,     2)
    env.def_primitive(:"assq",    ASSQ,      2)
    env.def_primitive(:"assv",    ASSV,      2)
    env.def_primitive(:"boolean?", BOOLEANQ,  1)
    env.def_primitive(:"caaaar",         CXR,       1)
    env.def_primitive(:"caaadr",         CXR,       1)
    env.def_primitive(:"caaar",          CXR,       1)
    env.def_primitive(:"caadar",         CXR,       1)
    env.def_primitive(:"caaddr",         CXR,       1)
    env.def_primitive(:"caadr",          CXR,       1)
    env.def_primitive(:"caar",           CXR,       1)
    env.def_primitive(:"cadaar",         CXR,       1)
    env.def_primitive(:"cadadr",         CXR,       1)
    env.def_primitive(:"cadar",          CXR,       1)
    env.def_primitive(:"caddar",         CXR,       1)
    env.def_primitive(:"cadddr",         CXR,       1)
    env.def_primitive(:"caddr",     THIRD,     1)
    env.def_primitive(:"cadr",          SECOND,    1)
    env.def_primitive(:"car",     CAR,       1)
    env.def_primitive(:"cdaaar",         CXR,       1)
    env.def_primitive(:"cdaadr",         CXR,       1)
    env.def_primitive(:"cdaar",          CXR,       1)
    env.def_primitive(:"cdadar",         CXR,       1)
    env.def_primitive(:"cdaddr",         CXR,       1)
    env.def_primitive(:"cdadr",          CXR,       1)
    env.def_primitive(:"cdar",           CXR,       1)
    env.def_primitive(:"cddaar",         CXR,       1)
    env.def_primitive(:"cddadr",         CXR,       1)
    env.def_primitive(:"cddar",          CXR,       1)
    env.def_primitive(:"cdddar",         CXR,       1)
    env.def_primitive(:"cddddr",         CXR,       1)
    env.def_primitive(:"cdddr",          CXR,       1)
    env.def_primitive(:"cddr",           CXR,       1)
    env.def_primitive(:"cdr",     CDR,       1)
    env.def_primitive(:"char->integer",  CHARTOINTEGER,      1)
    env.def_primitive(:"char-alphabetic?",CHARALPHABETICQ,      1)
    env.def_primitive(:"char-ci<=?",     CHARCICMP+LE, 2)
    env.def_primitive(:"char-ci<?" ,     CHARCICMP+LT, 2)
    env.def_primitive(:"char-ci=?" ,     CHARCICMP+EQ, 2)
    env.def_primitive(:"char-ci>=?",     CHARCICMP+GE, 2)
    env.def_primitive(:"char-ci>?" ,     CHARCICMP+GT, 2)
    env.def_primitive(:"char-downcase",  CHARDOWNCASE,      1)
    env.def_primitive(:"char-lower-case?",CHARLOWERCASEQ,      1)
    env.def_primitive(:"char-numeric?",  CHARNUMERICQ,      1)
    env.def_primitive(:"char-upcase",    CHARUPCASE,      1)
    env.def_primitive(:"char-upper-case?",CHARUPPERCASEQ,      1)
    env.def_primitive(:"char-whitespace?",CHARWHITESPACEQ,      1)
    env.def_primitive(:"char<=?",        CHARCMP+LE, 2)
    env.def_primitive(:"char<?",         CHARCMP+LT, 2)
    env.def_primitive(:"char=?",         CHARCMP+EQ, 2)
    env.def_primitive(:"char>=?",        CHARCMP+GE, 2)
    env.def_primitive(:"char>?",         CHARCMP+GT, 2)
    env.def_primitive(:"char?",   CHARQ,     1)
    env.def_primitive(:"close-input-port", CLOSEINPUTPORT, 1)
    env.def_primitive(:"close-output-port", CLOSEOUTPUTPORT, 1)
    env.def_primitive(:"complex?", NUMBERQ,   1)
    env.def_primitive(:"cons",    CONS,      2)
    env.def_primitive(:"cos",     COS,       1)
    env.def_primitive(:"current-input-port", CURRENTINPUTPORT, 0)
    env.def_primitive(:"current-output-port", CURRENTOUTPUTPORT, 0)
    env.def_primitive(:"display",        DISPLAY,   1, 2)
    env.def_primitive(:"eof-object?",    EOFOBJECTQ, 1)
    env.def_primitive(:"eq?",     EQQ,       2)
    env.def_primitive(:"equal?",  EQUALQ,    2)
    env.def_primitive(:"eqv?",    EQVQ,      2)
    env.def_primitive(:"eval",           EVAL,      1, 2)
    env.def_primitive(:"even?",          EVENQ,     1)
    env.def_primitive(:"exact?",         INTEGERQ,  1)
    env.def_primitive(:"exp",     EXP,       1)
    env.def_primitive(:"expt",    EXPT,      2)
    env.def_primitive(:"force",          FORCE,     1)
    env.def_primitive(:"for-each",       FOREACH,   1, n)
    env.def_primitive(:"gcd",            GCD,       0, n)
    env.def_primitive(:"inexact?",       INEXACTQ,  1)
    env.def_primitive(:"input-port?",    INPUTPORTQ, 1)
    env.def_primitive(:"integer->char",  INTEGERTOCHAR,      1)
    env.def_primitive(:"integer?",       INTEGERQ,  1)
    env.def_primitive(:"lcm",            LCM,       0, n)
    env.def_primitive(:"length",  LENGTH,    1)
    env.def_primitive(:"list",    LIST,      0, n)
    env.def_primitive(:"list->string", LISTTOSTRING, 1)
    env.def_primitive(:"list->vector",   LISTTOVECTOR,      1)
    env.def_primitive(:"list-ref", LISTREF,   2)
    env.def_primitive(:"list-tail", LISTTAIL,  2)
    env.def_primitive(:"list?",          LISTQ,     1)
    env.def_primitive(:"load",           LOAD,      1)
    env.def_primitive(:"log",     LOG,       1)
    # env.def_primitive(:"macro-expand",   MACROEXPAND,1)
    env.def_primitive(:"make-string", MAKESTRING,1, 2)
    env.def_primitive(:"make-vector",    MAKEVECTOR,1, 2)
    env.def_primitive(:"map",            MAP,       1, n)
    env.def_primitive(:"max",     MAX,       1, n)
    env.def_primitive(:"member",  MEMBER,    2)
    env.def_primitive(:"memq",    MEMQ,      2)
    env.def_primitive(:"memv",    MEMV,      2)
    env.def_primitive(:"min",     MIN,       1, n)
    env.def_primitive(:"modulo",         MODULO,    2)
    env.def_primitive(:"negative?",      NEGATIVEQ, 1)
    env.def_primitive(:"newline", NEWLINE,   0, 1)
    env.def_primitive(:"not",     NOT,       1)
    env.def_primitive(:"null?",   NULLQ,     1)
    env.def_primitive(:"number->string", NUMBERTOSTRING,   1, 2)
    env.def_primitive(:"number?", NUMBERQ,   1)
    env.def_primitive(:"odd?",           ODDQ,      1)
    env.def_primitive(:"open-input-file",OPENINPUTFILE, 1)
    env.def_primitive(:"open-output-file", OPENOUTPUTFILE, 1)
    env.def_primitive(:"output-port?",   OUTPUTPORTQ, 1)
    env.def_primitive(:"pair?",   PAIRQ,     1)
    env.def_primitive(:"peek-char",      PEEKCHAR,  0, 1)
    env.def_primitive(:"positive?",      POSITIVEQ, 1)
    env.def_primitive(:"procedure?", PROCEDUREQ,1)
    env.def_primitive(:"quotient",       QUOTIENT,  2)
    env.def_primitive(:"rational?",      INTEGERQ, 1)
    env.def_primitive(:"read",    READ,      0, 1)
    env.def_primitive(:"read-char",      READCHAR,  0, 1)
    env.def_primitive(:"real?",         NUMBERQ,   1)
    env.def_primitive(:"remainder",      REMAINDER, 2)
    env.def_primitive(:"reverse", REVERSE,   1)
    env.def_primitive(:"round",  ROUND,     1)
    #env.def_primitive(:"set-car!",SETCAR,    2)
    #env.def_primitive(:"set-cdr!",SETCDR,    2)
    env.def_primitive(:"sin",     SIN,       1)
    env.def_primitive(:"sqrt",    SQRT,      1)
    env.def_primitive(:"string", STRING,    0, n)
    env.def_primitive(:"string->list", STRINGTOLIST, 1)
    env.def_primitive(:"string->number", STRINGTONUMBER,   1, 2)
    env.def_primitive(:"string->symbol", STRINGTOSYMBOL,   1)
    env.def_primitive(:"string-append",  STRINGAPPEND, 0, n)
    env.def_primitive(:"string-ci<=?",   STRINGCICMP+LE, 2)
    env.def_primitive(:"string-ci<?" ,   STRINGCICMP+LT, 2)
    env.def_primitive(:"string-ci=?" ,   STRINGCICMP+EQ, 2)
    env.def_primitive(:"string-ci>=?",   STRINGCICMP+GE, 2)
    env.def_primitive(:"string-ci>?" ,   STRINGCICMP+GT, 2)
    env.def_primitive(:"string-length",  STRINGLENGTH,   1)
    env.def_primitive(:"string-ref", STRINGREF, 2)
    env.def_primitive(:"string-set!", STRINGSET, 3)
    env.def_primitive(:"string<=?",      STRINGCMP+LE, 2)
    env.def_primitive(:"string<?",       STRINGCMP+LT, 2)
    env.def_primitive(:"string=?",       STRINGCMP+EQ, 2)
    env.def_primitive(:"string>=?",      STRINGCMP+GE, 2)
    env.def_primitive(:"string>?",       STRINGCMP+GT, 2)
    env.def_primitive(:"string?", STRINGQ,   1)
    env.def_primitive(:"substring", SUBSTRING, 3)
    env.def_primitive(:"symbol->string", SYMBOLTOSTRING,   1)
    env.def_primitive(:"symbol?", SYMBOLQ,   1)
    env.def_primitive(:"tan",     TAN,       1)
    env.def_primitive(:"vector",    VECTOR,    0, n)
    env.def_primitive(:"vector->list",   VECTORTOLIST, 1)
    env.def_primitive(:"vector-length",  VECTORLENGTH, 1)
    env.def_primitive(:"vector-ref",     VECTORREF, 2)
    env.def_primitive(:"vector-set!",    VECTORSET, 3)
    env.def_primitive(:"vector?",    VECTORQ,   1)
    env.def_primitive(:"write",   WRITE,     1, 2)
    env.def_primitive(:"write-char",   DISPLAY,   1, 2)
    env.def_primitive(:"zero?",          ZEROQ,     1)
    return env
  end

  def truth(x)
    x
  end

  def apply(interpreter, args)
    puts "ARGS ==============> #{args}"
    nargs = args.length
    if nargs < min_args then
      raise "too few args, #{nargs}, for #{name}: #{args}"
    elsif nargs > max_args
      raise "too many args, #{nargs}, for #{name}: #{args}"
    end
    x = args.first
    y = args.second
    
    case @id_number
    when NOT then       	return x == false
    when BOOLEANQ then  	return x == true || x == false
      
      # # # #   SECTION 6.2 EQUIVALENCE PREDICATES
    when EQVQ then 		return eqv?(x,y)
    when EQQ then 		return x === y
    when EQUALQ then  	return x == y
      
      # # # #   SECTION 6.3 LISTS AND PAIRS
    when PAIRQ then  	return x.is_a?(Pair)
    when LISTQ then         return list?(x)
    when CXR 
        i = name.length - 2
        while i >= 1 do
          x = name[i].chr == 'a' ? x.first  : x.rest
          i -= 1
        end
        return x
    when CONS then  	return Pair.new(x, y)
    when CAR then  	        return x.first
    when CDR then  	        return x.rest
    when SETCAR then        return x.first = y
    when SETCDR then        return x.rest = y
    when SECOND then  	return x.second
    when THIRD then  	return x.third
    when NULLQ then         return x == nil
    when LIST then  	return args
    when LENGTH then  	return length(x)
    when APPEND then        return (args == nil) ? nil : append(args)
    end

    def append(args)
      raise "not implemented"
    end

    def list?(x)
      return true if x.nil?
      return list?(x.rest) if x.is_a?(Pair)
      return false
    end

    def eqv?(x, y)
      raise "not implemented"
    end

    def length(x)
      return 0 if x.nil?
      return 1 + length(x.rest) if x.is_a?(Pair)
      raise "Non-pairs have no length"
    end
    
  end
end
