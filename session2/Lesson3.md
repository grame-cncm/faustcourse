## Lesson 3

Welcome to lesson 3. In this lesson, we're going to look at additional primitives, in particular arithmetic operations on signals, like addition, multiplication of signals and much more.

### Arithmetic

[Slide 16: Arithmetic Operations]

All standard arithmetic operations on numbers exist in Faust as operations on signals.

For instance, signals can be summed, subtracted, multiplied, raised to the
power, divided, take the modulo of one signal by the other.

As an example let's do a simple _volume control_ by assembling three primitives: a wire,
a vertical slider and a multiplication.

[Slide 17: A simple volume control]

[**demo**]

    process = _, vslider("level", 0, 0, 1, 0.01) : * ;


We use the parallel composition to combine the wire and the slider. The resulting circuit
has two output signals. It can therefore be connected to a multiplier using the sequential composition
operator `:`.

### Core Notation vs Infix Notation

Let say that we would like to express our level control as a value between 0 and 100, instead of 0 and 1. We will have to scale down the signal produced by the slider by 100.

[**demo**]

    process = _, (vslider("level", 0, 0, 100, 1), 100 : /) : * ;

The notation used here (called the core notation) starts to be a bit complex. But you
can use a more usual _infix_ notation as in this example:

[**demo**]

    process = _, vslider("level", 0, 0, 100, 1) / 100 : * ;

Or even:

[**demo**]

    process = _ * vslider("level", 0, 0, 100, 1) / 100 ;

All these examples are equivalent. It is really a matter of taste et readability.

[SLIDE 18: type of notations]

This slide summarizes the different notations you can use, and how they are translated
into core syntax.



### Comparison

All standard comparison operations on numbers are available in Faust.
But there is an important difference between comparing numbers and signals.
If we compare two numbers the result is either true or false.

But what happens when we compare two signals that evolve in time ?
The result is no more simply true or false, but will evolve in time according to the
instantaneous values of the two signals we compare. In other words the result of comparing
two signals is also a signal. The value of this signal is 1 when the result is true and 0
otherwise.

[Slide 19: Comparison Operations]

You can compare 2 signals to see when one is smaller than the other, smaller
or equal, greater, greater or equal, equal, and different.

The semantics of greater than comparison is illustrated in the following slide:

[Slide 20: Comparison Semantics]

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

[Slide 21: Bitwise operations]

The `&`, `|`, and `xor` are typically used to combine the result of comparison
operations. The left and right shift operations are less commonly used but
useful for specific cases when you want to manipulate the bit content of
samples.

### Trigonometric

Most standard trigonometric operations can be carried out in Faust as shown on
the screen.

[Slide 22: Trigonometric functions]

For instance, we can take the arc cosine of a signal, its arc sine, arc
tangent, arc tangent on 2 signals, cosine, sine, and tangent.

Let's create a sine wave oscillator from scratch to show the usage of the sine or cosine
function.

[Slide 23: Sine-Wave oscillator]

[**demo**]

    phasor(f) = f/44100 : (+,1:fmod) ~_;
    process = phasor(440) * 6.28318530718 : sin;


We start by defining a `phasor`, a phase generator that produces a periodic sawtooth signal of frequency f. Then we multiply the output signal by `2 PI`  and take the sine.

### Log and Exponential

[Slide 24: Log and Exponential]

Log and exponential operations are often used to convert signals between linear and dB
scales, or between piano key numbers and Hz.

### Min, Max and other functions (move after comparison)

Other mathematical operations are available as primitives in Faust as shown on
the screen.

[Slide 25: Min, Max and other functions]

Let's take a look at 2 very useful primitives: min and max. Min compares 2
input signals and always output the sample with the smallest value. Inversely
max compares 2 input signals and always output the sample with the greatest
value.

[Slide 26: Max and Min semantics]

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

[SLIDE 27: Selectors and Casting Functions]

Selectors are used to select between signals. For example the `select2` primitive
has 3 input signals. The first one is the selector signal and it is used to select between the two other signals depending on its value 0 or 1.

Let see an example:

[**demo**]

    import("stdfaust.lib");
    process = 	button("440/880"), os.osc(440), os.osc(880) : select2;

The `select3` primitive is just an extension of the `select2` as demonstrated in the following example:

[**demo**]

    import("stdfaust.lib");
    process = 	(hslider("selector", 0, 0, 2.99, 0.1) : int),
                os.osc(440),
                os.osc(880),
                os.osc(440*4)
                : select3;

In this example we use a slider to select the signal we want to ear. The selection signal is
produced by a slider. It is therefore a floating point signal that is converted into an
integer signal using the `int` operator. The reverse operation is also possible. An integer
signal can be converted into a floating point signal using the `float` primitive.


This example concludes lesson 3. In the next lesson we are going to see the time related
primitives, in particular the delay operation.