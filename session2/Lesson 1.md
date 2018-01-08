## Lesson 1: Learning Faust

In order to really master Faust, the following elements must be learned:

[Slide 1: What it takes to learn Faust]

* Primitives: the available build-in blocks so to speak
* Syntax: how to assemble these primitives to create a program
* Semantics: the meaning of the resulting program, what it does
* Link between a Faust code, its graphical representation as a block-diagram, 
and its mathematical semantics as a function on signals
* Libraries (lesson TODO)
* Tooling, architectures, deployment (lesson TODO)

Libraries and tooling will be covered in future lessons, here we'll focus on
the first fours topics of this list.

[Slide 2: primitives are built-in operations of the language]

A primitive is an elementary built-in operation of the language. For example, 
the primitive `+` takes two input 
signals and adds their samples together to produce the output signal. The 
primitive `abs` is another built-in operation that takes an input signal and 
computes the absolute value of each sample to produce the output signals.

You can use the online editor to look at the block diagram corresponding to
these primitives [do it: demo of `process = +`/`process = abs` in the editor].

Primitives are the building blocks of Faust. You can think of them as the 
elementary components (resistors, transistors, etc.) of an electronic circuit. 
There are currently about 60 different primitives predefined in the language. 

[Slide 3: primitives are like components of an audio circuit]

_Syntax_ and _Semantics_ are two important concepts when learning any 
programming language. The _syntax_ tells you how to write well-formed programs. 
The _semantics_ tells you the "meaning" of these programs. A good analogy could
be the difference the electronic circuit of a distortion and the behavior of
this electronic circuit as a distortion.

[Slide 4: Syntax and Semantics; distortion circuit vs. distortion stombox TODO]

In order to tell the meaning of a Faust program, we will use simple 
mathematical expressions on signals, that themselves are a function of time. 
For example, to express the fact that the
`+` primitive in Faust adds 2 input signals, we can give the mathematical
relationship between the output signal z(t) and the 2 input signals x(t) and
y(t) by saying that z(t) = x(t) + y(t) where t is time.

[Slide 5: Code, Block-diagrams and Mathematical Semantics]

As you can see we basically have 3 different kinds of representation: the 
Faust program itself, its visual representation as a block diagram, and 
its mathematical semantics as a function on signals. In this session, we will
learn how to go from one representation to another. For example, if you have a
block diagram, it's important to know how to code it in Faust. Usually when
you start programming in Faust, you might begin by drawing the diagram of an
algorithm before actually coding it.

As a short exercise, try to find the semantics of the following block diagram:

[Slide 6: Quiz]

You can now pause the video!

[Slide 7: Quiz Answer]

<Conclusion Lesson 1>
