start Toplevel

restrict Symbol: [a-zA-Z0-9-_]
restrict LAYOUT: [\t\n\s]
restrict Number: [0-9]

# Toplevel definitions
cf top Toplevel ::= Form+

cf nil Form ::= "(" ")"
cf list Form ::= "(" Form+ ")"
cf pair Form ::= "(" Form+ "." Form ")"
cf string Form ::= String

# charclass has to go
cf cclass Form ::= CharClass
cf symbol Form ::= Symbol
cf number Form ::= Number
cf bool Form ::= Bool
cf quote Form ::= "'" Form
cf unquote Form ::= "," Form
cf unquote-splicing Form ::= ",@" Form
cf quasiquote Form ::= "`" Form


# Booleans

lex true Bool ::= "#t"
lex false Bool ::= "#f"

# Symbols
lex id Symbol ::= Head IdChar*
lex id SymbolBla ::= Head IdChar*
lex head Head ::= [a-zA-Z_]

lex char IdChar ::= [a-zA-Z0-9-_]

lex str String ::= ["] StrChar* ["]
lex qq StrChar ::= [\] ["]
lex qs StrChar ::= [\] [\]
lex char StrChar ::= [A-Za-z0-9\s\t\n;<>:',.|/?!@#$%^&*()\-_+={}\[\]`~!] 

lex digits Number ::= Digit+
lex digits NumberBla ::= Digit+
lex digit Digit ::= [0-9]

# Character classes
lex charclass CharClass ::= "[" Range* Char* "]"
lex range Range ::= AlphaNum "-" AlphaNum
lex newline Char ::= "\n"
lex tab Char ::= "\n"
lex space Char ::= "\s"
lex openbr Char ::= "\]"
lex closebr Char ::= "\["
lex dash Char ::= "\-"
lex other Char ::= [a-zA-Z0-9!@#$%^&*()_=+}{:;"'<>,.?/|\`~]
lex alphanum AlphaNum ::= [a-zA-Z0-9]

lex layout LAYOUT ::= CommentOrWhitespace*
lex layout CommentOrWhitespace ::= Comment
lex layout CommentOrWhitespace ::= Whitespace
lex layout Comment ::= "//" CommentChar+ [\n]
lex layout CommentChar ::= [A-Za-z0-9\s\t";:',.<>|\\/?!@#$%^&*()\-_+={}`~!]
lex layout Whitespace ::= [\s\n\t]
