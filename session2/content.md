# Session 2
Welcome to this new session. In the previous session you have seen some code examples includind a simple occarina made by using some predefined functions of the standard Faust Libraries. In this session we will go into more details and learn both the _syntax_ and the _semantics_ of Faust.

## lesson 1 (syntax and semantics)

_Syntax_ and _Semantics_ are two important notions when learning any programming language. The _syntax_ tells you how to write well formed programs. The _semantics_ tells you the "meaning" of these programs.

In the case of Faust, you can think of a program as a kind of electronic circuit that computes audio signals. The syntax will tell you how to build the circuit from elementary building blocks. The semantics will tell you what the circuit computes. 


### definitions

Before we go deeper into the details of the syntax and the semantics of Faust, lets define some terms that we will use.

#### Signal
Informally a signal is a value that changes over time, for example the variation of air pressure at a particular point. 

In Faust a signal is a discrete function of time. This means that we can know the value of a signal at integer time values 0, 1, etc. but -1, -2, etc., but not at time 3.5 or 9.8. 

If `s` is a signal `s(t)` represents the value of this signal at time `t`

A particularity of Faust's signals is that their value before time 0 


The value of a signal s at time t is written s(t).Thevaluesofsignalsareusuallyneededstartingfromtime0.But to take into account delay operations, negative times are possible and are always mapped to zeros. Therefore for any Faust signal s we have ∀t < 0,s(t) = 0. In operational terms this corresponds to assuming that all delay lines are signals initialized with 0s.


#### Primitive
A primitive is an elementary built-in operation of the language. For example, the primitive `+` is a built-in operation that takes two input signals and adds their samples together to produce the output signal. The primitive `abs` is another built-in operation that takes an input signal and computes the absolute value of each sample to produce the output signals.

Primitives are the building blocks of Faust. You can think of them as the elementary components (resistors, transistors, etc.) of an electronic circuit. There are currently about 60 different primitives predefined in the language. 

#### Signal processor



#### Expressions
An expressions is pretty much everything that can be build on top of primitives

an , predefined 'unit of processing' available to a programmer of a given machine, or can be an atomic element of an expression in a language.

Primitives are units with a meaning, i.e., a semantic value in the language. Thus they are different from tokens in a parser, which are the minimal elements of syntax.


The syntax of Faust is quite simple. You start form elementary building blocks, for example _numbers_ like `3.14159` or `0`, _arithmetic operations_ like `*` or `+`, and you combine them to create more complex program. 


#### Composition operation
A composition operation is a 






