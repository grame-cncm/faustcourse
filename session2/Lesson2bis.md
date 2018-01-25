## Lesson 2bis

Welcome to lesson 3. In this lesson, we're going to look at additional primitives, in particular arithmetic
operations on signals. For example the Faust primitive `+` is an audio circuit with
two input signals and one output signal.

### Arithmetic

[Slide 16: Arithmetic Operations]

All standard arithmetic operations on numbers exist in Faust as operations on signals.



For instance, signals can be summed, subtracted, multiplied, raised to the
power, divided, take the modulo of one signal by the other.

As an example let's do a simple _volume control_ by assembling three primitives: a wire,
a vertical slider and a multiplication.


[**demo**]

    process = _, vslider("level", 0, 0, 1, 0.01) : * ;


We use the parallel composition to combine the wire and the slider. The resulting circuit
has two output signals. It can therefore be connected to a multiplier using the sequential composition
operator `:`.

### Core Notation vs Infix Notation

Let say that we would like to express our level control as a value between 0 and 100, instead of 0 and 1.
We will have to scale down the signal produced by the slider by 100.

[**demo**]

    process = _, (vslider("level", 0, 0, 100, 1), 100 : /) : * ;



### expressions

To end this lesson we would like to come back on how expressions are written in Faust. Let say that we want to multiply a signal by 0.5. We can write this in four different, but equivalent, ways. We can use Faust core syntax, infix notation, prefix notation, or partial application.

[SLIDE 50: type of notations]

In this slide we see the different notations of a very simple example, and how they are related to the core syntax.



### infix notation and syntactic sugar
What about doing a simple multiplication between two numbers? Let's say 2 and 3. Here is the Faust program to write:

[**demo**]

    process = 2, 3 : * ;

Sometimes it is more convenient to use the usual infix notation:

[**demo**]

    process = 2*3;


But this is just syntactic sugar for the core notation



### Comparison

All standard comparison operations on numbers are available in Faust.
But there is an important difference between comparing numbers and signals.
If we compare two numbers the result is either true or false.

But what happens when we compare two signals that evolve in time ?
The result is no more simply true or false, but will evolve in time according to the
instantaneous values of the two signals we compare. In other words the result of comparing
two signals is also a signal. The value of this signal is 1 when the result is true and 0
otherwise.

[Slide 18: Comparison Operations]

You can compare 2 signals to see when one is smaller than the other, smaller
or equal, greater, greater or equal, equal, and different.

The semantics of greater than comparison is illustrated in the following slide:

[Slide 19: Comparison Semantics]

Here is a small program that compares the value of a sine oscillator with a threshold
between 0 and 1, controlled by a slider. You will ear the resulting signal which is 1
when the condition is true and 0 otherwise

[**demo**]

    import("stdfaust.lib");
    process = os.oscsin(10), vslider("threshold", 0, 0, 1, 0.01) : >;

When the threshold is 0, the condition is true during half the period and false during the
other half. The signal produced is a square wave in the range 0,1.

When we increase the threshold the portion of samples at 1 will shrink until the
threshold reaches one. In this case the condition is always false and the signal produced is
silence.


### Bitwise

As for arithmetic and comparison operations, most standard bitwise operations
on integers are available in Faust.

[Slide 20: Bitwise operations]

The `&`, `|`, and `xor` are typically used to combine the result of comparison
operations. The left and right shift operations are less commonly used but
useful for specific cases when you want to manipulate the bit content of
samples.

### Trigonometric

Most standard trigonometric operations can be carried out in Faust as shown on
the screen.

[Slide 21: Trigonometric functions]

For instance, we can take the arc cosine of a signal, its arc sine, arc
tangent, arc tangent on 2 signals, cosine, sine, and tangent.

Let's create a sine wave oscillator from scratch to show the usage of the sine or cosine
function.

[Slide 22: Sine-Wave oscillator]

[**demo**]

    phasor(f) = f/44100 : (+,1:fmod) ~_;
    process = phasor(440) * 6.28318530718 : sin;


We start by defining a `phasor`, a phase generator that produces a periodic sawtooth signal of frequency f. Then we multiply the output signal by `2 PI`  and take the sine.

### Log and Exponential

Bla bla

[Slide 23: Log and Exponential]

Bla bla

### Min, Max and other functions (move after comparison)

Other mathematical operations are available as primitives in Faust as shown on
the screen.

[Slide 24: Min, Max and other functions]

Let's take a look at 2 very useful primitives: min and max. Min compares 2
input signals and always output the sample with the smallest value. Inversely
max compares 2 input signals and always output the sample with the greatest
value.

[Slide 25: Max and Min semantics]

As an example, a simple dirty distortion effect can be implemented using these
2 primitives and a multiplication. Let's try to run it in the Faust online editor.
WARNING: be careful if you're wearing as this might create feedback!

[**demo**]

    gain = hslider("gain",0.05,0,1,0.01);
    process = *(100) : min(1) : max(-1) : *(gain);


The input signal is first multiplied by a 100 which corresponds to the drive
parameter of the distortion. Then we hard-clip it between -1 and 1 using the
min and max primitives in series. It might seem counter-intuitive to use 1 with
min and -1 with max but that's right thing to do. Indeed, we want the minimum
value between 1 and the input signal in order for the output signal to not
exceed 1. Similarly, we want the maximum value between -1 and the input signal
in order for the output signal to not be inferior to -1.

### Selectors and Casting Functions

[SLIDE 26: Selectors and Casting Functions]

[**demo**]

    import("stdfaust.lib");
    process = 	button("440/880"), os.osc(440), os.osc(880) : select2;

[**demo**]

    import("stdfaust.lib");
    process = 	(hslider("selector", 0, 0, 2.99, 0.1) : int),
                os.osc(440),
                os.osc(880),
                os.osc(440*4)
                : select3;


