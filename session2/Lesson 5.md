## Lesson 5: Programming by composition
- BDA overview
- priority (quiz: expressions equivalentes)
- parallel ()
- sequential
- split
- merge
- recursion

### Introduction
In this lesson we are going to see the composition operations that are at the heart of the language.

Faust is based on the idea of combining audio circuits together to form more complex ones. The way to combine these circuits is by using a set of five 'wiring' operations. Each of these operations takes two circuits and connects them in a particular way. These operations define a kind of "arithmetic" on circuits.

[SLIDE 34: composition operations]

For example the sign column (:) is used for sequential composition. It connects all the outputs of the first circuit to the corresponding input of the second circuit. For this operation to take place, the number of outputs of the first circuit and the number of inputs of the second one must identical.

Like in arithmetic expressions, composition operations have precedence rules that defines the order in which operations are done. These precedences have been fixed so that a sequence of parallel circuits, a very common structure, can be written without parenthesis.

The highest precedence operation is the recursive composition. It has precedence 4. Then we have the parallel composition (with precedence 3), then sequential composition (with precedence 2) and finally the split and merge compositions (with precedence 1).

[SLIDE 35: composition operations precedence]
Let see some examples. bla bla...

Let's now review in details these five composition operations starting with the sequential composition.

### Sequential composition

[SLIDE 36: sequential composition]
The sequential composition connects the outputs of A to the inputs of B. The first output of A is connected to the first input of B, etc. The number of outputs of A must be equal to the number of inputs of B otherwise the Faust compiler will flag an error.

[DEMO]

Let's see what happens if we try to connect `+` that has one output to `*` that has two inputs

```
process = + : *;
```

When we try to run the program we get an error message:
“Error in sequential composition (A:B).
The number of outputs (1) of A = + must be equal to the number of inputs (2) of B : *"

### Parallel composition

[SLIDE 37: parallel composition]

The parallel composition is probably the simplest one. It places the two circuits one on top of the other, without connections. The inputs of the resulting circuit are the inputs of A and B in that order. The outputs of the resulting circuit are the outputs of A and B in that order. In this example the resulting circuit has 3 inputs and 3 outputs.

There are no constraints on the number of inputs and outputs of the circuits that can be composed in parallel.

[QUIZ: select the middle signal among three]
Using the wire and the cut primitives and the parallel composition, define a circuit that takes three input signals but outputs only the middle one.

[ANSWER: select the middle signal among three]
Here is the solution: we place in parallel a cut, a wire and another cut. In generale if we want to select one signal among n, we can create a circuit with n-1 cut and one wire.

### Split composition

[SLIDE 40: split composition]

The split composition A<:B is used to distribute the outputs of A to the inputs of B.
For the operation to be valid the number of inputs of B must be a multiple of the number of outputs of A.

[QUIZ: Two Ways Stereo Splitter]
This code splits a stereo cable into two stereo cables. Write the Faust code and draw the bloc-diagram corresponding.

[ANSWER: Two Ways Stereo Splitter]
Here is the answer. First draw the two wires in parallel on the left side, then draw the four wires in parallel on the right, and then do the connections between them.


### Merge composition

[SLIDE 43: merge composition]

The merge composition A:>B is the dual of the split composition. The number of outputs of A must be a multiple of the number of inputs of B. For example a merge composition can be realized between a A has four outputs and a B with two inputs. Note than when several output signals are merge into an input signals, the signals are added together. In other words, `_,_ :> _` is equivalent to `+`.

[QUIZ: Add three signals together without using the + primitive]
[ANSWER: Add three signals together without using the + primitive]


### Recursive composition

[SLIDE 46: recursive composition]
The recursive composition allows to create feedback loops into a circuit. The condition for this operation to be possible is that the number of inputs of B must be less or equals to the number of output of A, and the number of outputs of B must be less or equal to the number of inputs of A.

SLIDE 47: valid/invalid recursive compositions]
For example `+ ~ _` is a valid expressions because it respects these two conditions. But `_ ~ +` is not a valid expression because  `+` have two inputs while `_` provides only one output.

[QUIZ 48: valid/invalid recursive compositions]
[ANSWER 49: valid/invalid recursive compositions]

### Examples

#### Example 1: a noise generator

In this example we are going to implement a white noise generator.

```
// random  = (_,12345:+) ~ (_,1103515245:*);    // core syntax
// random  = _+12345 ~ _*1103515245;            // infix notation
// random  = +(12345) ~ *(1103515245);          // prefix notation

random  = +(12345) ~ *(1103515245);

noise   = random/2147483647.0;

process = noise * vslider("Volume[style:knob]", 0, 0, 1, 0.1) <: _,_;

```

#### Example 2: a simple echo

In this example we are going to implement a very simple echo. We will make use of the recursive composition to create the feedback in the circuit.

```
import("stdfaust.lib");

echo(d,f) = + ~ (@(d) : *(f));
process = button("play") : pm.djembe(60, 0.3, 0.4, 1) : echo(44100/4, 0.75);

```

Let's look at the resulting block-diagram

#### Example 3 : a ping-pong stereo echo
In this example we are creating a left-right ping pong echo. This can be easily implemented by having two echo in parallel for the left and right channel and slightly delay the right channel

```
import("stdfaust.lib");

echo(d,f) = + ~ (@(d) : *(f));
pingpong(d,f) = echo(2*d,f) <: _, @(d);

process = button("play") : pm.djembe(60, 0.3, 0.4, 1) : pingpong(44100/4, 0.75);

```



