# Session 2: Digging Into Faust’s Syntax and Semantics

Welcome to this new session! In the previous session you have seen some code 
examples including a simple ocarina made by using some predefined functions of 
the standard Faust Libraries. In this session we will go into more details and 
learn both the _syntax_ and the _semantics_ of Faust.

## Lesson 1: Learning Faust

In order to really master Faust, the following elements must be learned:

[slide 1 TODO]

* Primitives: the available buildin blocks so to speak
* Syntax: how to assemble this primitives to create a program
* Semantics: the meaning of the resulting program, what it does
* Link between a Faust code, its graphical representation as a block-diagram, 
and its mathematical semantics as a function on signals
* Libraries (lesson TODO)
* Tooling, architectures, deployment (lesson TODO)

Libraries and tooling will be covered in future lessons, here we'll focus on
the first fours topics of this list.

[slide 2: primitive TODO]

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

[slide 3: TODO]

_Syntax_ and _Semantics_ are two important concepts when learning any 
programming language. The _syntax_ tells you how to write well formed programs. 
The _semantics_ tells you the "meaning" of these programs. A good analogy could
be the difference the electronic circuit of a distortion and the behavior of
this electronic circuit as a distortion.

[slide 4: distortion circuit vs. distortion stombox TODO]

In order to tell the meaning of a Faust program, we will use simple 
mathematical expressions on signals, that themselves are a function of time. 
For example, to express the fact that the
`+` primitive in Faust adds 2 input signals, we can give the mathematical
relationship between the output signal z(t) and the 2 input signals x(t) and
y(t) by saying that z(t) = x(t) + y(t) where t is time.

[slide 5: TODO]

As you can see we basically have 3 different kinds of representation: the 
Faust program itself, its visual representation as a block diagram, and 
its mathematical semantics as a function on signals. In this session, we will
learn how to go from one representation to another. For example, if you have a
block diagram, it's important to know how to code it in Faust. Usually when
you start programming in Faust, you might begin by drawing the diagram of an
algorithm before actually coding it.

As a short exercise, try to find the semantics of the following block diagram:

[slide 6: TODO]

You can now pause the video!

[slide 7: TODO]

## Lesson 2: Signals and Time Models

Informally, a signal is a value that changes over time, for example the 
variation of air pressure producing a sound. In other words, a signal is a 
function transforming a time input into a value output. This value is
also called a sample. 

The full scale audio range for samples is typically a floating point value 
between -1 and +1. But of course, Faust can manipulate signals of arbitrary 
ranges that can also be integer signals.

[slide 8: TODO]

If we give a name to this signal for example s, then s(t) represents the 
value of the signal s at time t. 

Now let's define time a little bit better. Since we are interested in sampled
signals (also called discrete signal), here time is an integer. A signal is 
infinite both in the future and in the past but the value of time is 0 when the
Faust program starts.

## Lesson 3: Basic Faust Primitives

In this lesson, we're going to look at all the mathematical primitives of Faust.

### Numbers

Numbers and standard mathematical operations on numbers all have an equivalent 
on signals in Faust. For example, we already saw the `+` and the `abs` 
operations in lesson 1. 

Numbers in Faust are signal generators, elementary circuits with no input and
one output. In other words, a number in Faust produces an output signal whose 
samples are all equal to that number starting from time 0.

[slide 9: see slide 20 in FARM TODO] 

Note that the values of the samples of the signal produced by the number 1 in 
Faust are all 0 before time 0. 

### Arithmetic

All standard arithmetic operations can be carried out in Faust as shown on the
screen.

[slide 10: see slide 22 in FARM TODO]

For instance, signals can be summed, subtracted, multiplied, raised to the 
power, divided, take the modulo of one signal by the other, TODO: cast.

### Comparison

All standard comparison operations are available in Faust.
But there is an important difference between comparing numbers and signals. 
The output produced by a comparison operator in Faust is also a signal. The
value of this signal is one when the comparison is true and 0 when the 
comparison is false. Because the result is also time dependent (it is a signal),
comparison operators in Faust must be considered as signal processors just like 
any other arithmetic operation.   

[slide 11: TODO] + Faust example TODO

You can compare 2 signals to see when one is smaller than the other, smaller 
or equal, greater, greater or equal, equal, and different.

[slide 12: see slide 24 in FARM TODO]

### Bitwise

As for arithmetic and comparison operations, most standard bitwise operations 
on integers are available in Faust. 

[slide 13: see slide 23 in FARM TODO]

The `&`, `|`, and `xor` are typically used to combine the result of comparison
operations. The left and right shift operations are less commonly used but 
useful for specific cases when you want to manipulate the bit content of
samples. 

### Trigonometric

Most standard trigonometric operations can be carried out in Faust as shown on 
the screen.

[slide 14: see slide 25 in FARM TODO]

For instance, we can take the arc cosine of a signal, its arc sine, arc
tangent, arc tangent on 2 signals, cosine, sine, and tangent. 

### Other Math Operations

Other mathematical operations are available as primitives in Faust as shown on
the screen.

[slide 14: see slide 26 in FARM TODO]

Let's take a look at 2 very useful primitives: min and max. Min compares 2
input signals and always output the sample with the smallest value. Inversely
max compares 2 input signals and always output the sample with the greatest
value. 

As an example, a simple dirty distortion effect can be implemented using these
2 primitives and a multiply. Let's try to run it in the Faust online editor. 
WARNING: be carefule if you're wearing as this might create feedback!

```
gain = hslider("gain",0.05,0,1,0.01);
process = *(100) : min(1) : max(-1) : *(gain);
```

The input signal is first multiplied by a 100 which corresponds to the drive 
parameter of the distortion. Then we hard-clip it between -1 and 1 using the
min and max primitives in series. It might seem counter intuitive to use 1 with
min and -1 with max but that's right thing to do. Indeed, we want the minimum 
value between 1 and the input signal in order for the output signal to not 
exceed 1. Similarly, we want the maximum value between -1 and the input signal 
in order for the output signal to not be inferior to -1. 



#### Expressions
An expressions is pretty much everything that can be build on top of primitives

an , predefined 'unit of processing' available to a programmer of a given machine, or can be an atomic element of an expression in a language.

Primitives are units with a meaning, i.e., a semantic value in the language. Thus they are different from tokens in a parser, which are the minimal elements of syntax.


The syntax of Faust is quite simple. You start form elementary building blocks, for example _numbers_ like `3.14159` or `0`, _arithmetic operations_ like `*` or `+`, and you combine them to create more complex program. 


#### Composition operation
A composition operation is a 






