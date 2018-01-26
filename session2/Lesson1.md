# Session 2

## Lesson 1: Learning Faust

Welcome to session 2. This session is going to be a little bit more
computer science oriented. But we will keep it as simple as possible.
At the end of this session you will have all the information required
to program in Faust.


[Slide 1: What you will learn in this session]

This first lesson will give you a kind of overview of session 2.
Here is what you are going to learn:

* You will learn the _primitives_ of the language, which are the
predefined built-in blocks on top of which your are going to write more
complex programs
* You will learn also the _syntax_ of the language, the rules that you need to
follow to assemble these primitives in order to create well-defined programs.
* You will learn the _block-diagram representation_ of a Faust program. Faust is a
textual language but programs have a straight forward graphical representation.
* You will learn the _semantics_ of the language: how to understand
the meaning of a program, what it does (as you will see Faust programs are
like audio circuits that produce and transform audio signals).
* You will learn also how to navigate between all these different representations.
For example at the beginning, you will often start by drawing a block-diagram before coding
it in Faust.

There are others things that you will have to learn like _libraries_,
_Tooling_, _architectures_, _deployment_ but you will discover them in the next
sessions.

[Slide 2: primitives are built-in operations of the language]

A primitive is an elementary built-in operation of the language. For example,
the primitive `+` takes two input signals and adds their samples together to
produce the output signal. Don't be afraid by the formulas. It just says
that the value of output signal `y` at time `t`is equal to the sum of the
values of the two input signals `x0`and `x1` at time `t`.

The primitive `abs` is another built-in operation that takes an input signal and
computes the absolute value of each sample to produce the output signal.

You can use the online editor to look at the block diagram corresponding to
these primitives.

[**demo**]

    process = +;

[**demo**]

    process = abs;

[Slide 3: primitives are like components of an audio circuit]

Primitives are the building blocks of Faust. You can think of them as the
elementary components (resistors, transistors, etc.) of an electronic circuit.
There are currently about 60 different primitives predefined in the language.

[Slide 4: Syntax and Semantics; distortion circuit vs. distortion stombox TODO]

_Syntax_ and _Semantics_ are two important concepts when learning any
programming language. The _syntax_ tells you how to write well-formed programs.
The _semantics_ tells you the "meaning" of these programs, what it does when you
run it.

A good analogy could be the difference between the description of the electronic
circuit of a distortion and, the distortion effect itself, how it transforms the
sounds when you use it.

[Slide 5: Code, Block-diagrams and Mathematical Semantics]

In order to tell the meaning of a Faust program, we will use simple
mathematical expressions on signals, that explain how the output signals are computed according to the input signals.

For example, to express the fact that the `+` primitive in Faust adds 2 input signals,
we can give the mathematical relationship between the output signal y(t) and the 2 input
signals x0(t) and x1(t) by saying that y(t) = x0(t) + x1(t) where t is time.

As you can see we basically have 3 different kinds of representation: the
Faust program code itself, its visual representation as a block diagram, and
its mathematical semantics as a function on signals. In this session, we will
learn how to go from one representation to another. For example, if you have a
block diagram, it's important to know how to code it in Faust. Usually when
you start programming in Faust, you might begin by drawing the diagram of an
algorithm before actually coding it.

As a short exercise, try to find the semantics of the following block diagram:

[Slide 6: Quiz]

You can now pause the video!

[Slide 7: Quiz Answer]

This quiz concludes this first lesson of Session 2. You have now an idea
of what you are going to learn in the next lessons of this session.

