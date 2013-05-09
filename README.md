
CherryLisp
==========

This is a very immature, buggy, dog-slow prototype of a Lisp dialect
with dynamically extensible syntax using (full) context-free grammars.
Implemented in Ruby.

## Usage

To fire up a REPL, enter on the command line:

    > cd src
    > ruby -I. cherry.rb
    
Then try this:

    > (extend-syntax (abs Form ("|" Form "|")))
    (cf abs Form ("|" Form "|"))
    > |1|
    Unbound variable: abs
    > '|1|
    (abs 1)
    > (define abs (lambda (x) (if (geq x 0) x (min 0 x))))
    abs
    > |1|
    1
    > |(min 0 1)|
    1

For more examples see the accompanying report in `paper`. There's no
guarantee that they (still) will work, though.

There aren't many built-in primitives in CherryLisp and there's not
much of a standard library. For a list of primitives, see
`src/cherry/primitive.rb` and `src/cherry/primitives.rb`. Unlike most
Lisps, CherryLisp's built-ins all use alpha-numeric names. The
hypothesis is that a nice syntax can be built on top of the basic Lisp
layer using the syntax extension mechanisms. M-expressions anyone?

## Acknowledgments

The Lisp-side of the implementation is a complete rip-off of Peter
Norvig's [JScheme](http://norvig.com/jscheme.html). The parser
technology is based on techniques from Jan Reker's
[dissertation](http://homepages.cwi.nl/~paulk/dissertations/Rekers.pdf).
