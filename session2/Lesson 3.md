## Lesson 3: Basic Faust Primitives

In this lesson, we're going to look at most of Faust's primitives, the 
built-in functions of the language. You can think of these primitives as 
elementary audio circuits. For example the Faust primitive `+` is an audio
circuit with two input signals and one output signal. 

As you will discover, programming in Faust is essentially composing audio 
circuits together to build more complex ones. To compose these circuits we 
use a set of five composition operators: parallel composition, sequential 
composition, split composition, merge composition and recursive composition.  
We will present in greater details these composition operations in lesson 6. 

### Wire
Let start with the simplest primitive you can imagine: the _wire_. The Faust name
for a wire is `_` underscore, because somehow it looks like a wire !

Let's write a FAUST program that uses a wire to connect the audio input to the audio output:

```
process = _;
```

Before running this program, make sure that you set the audio level to the 
minimum. Otherwise, you may damage your loudspeakers, or worth, your ears! 

Now that you have set the audio volume to 0, starts the program and rise 
very slowly the volume to stay at the limit of the Larsen effect.

So what is the semantics of `_` ? (Remember that _semantics_ is just a fancy 
word for _meaning_). It is the _identity function_. The output signal 
produced by underscore is the same/identical as the input signal. In other words 
underscore is a _perfect_ cable that doesn't introduce any modification to 
the input signal. 

[SLIDE 9] 

The slide explains the meaning of underscore in more mathematical terms. Lets 
call `x(t)` the input signal of underscore and `y(t)` the output signal. We can 
express the meaning of underscore by saying that `y(t)=x(t)`.

Let say now that we want to create a stereo cable made of two wires.
How can we place two circuits in parallel ? 

[SLIDE 10: A cable made of two wires] 

We use for that the _parallel composition_ operator represented by the `,` 
(comma) sign.

### Cut
The primitive Cut, represented by the exclamation mark (`!`) can be used to cut-out a 
signal that we don't want to use. 

Let say that we have a stereo signal and that we only want to cut the left channel and keep the right channel. 
We can write the following program

```
process = !,_; 
```

[SLIDE 11: Keep only the right channel of a stereo cable]

[QUIZ] 
Write a Faust program that represents a quadriphonic cable

[SLIDE 12, QUIZ: A quadriphonic cable ?]

```
process = _,_,_,_; 
```
[SLIDE 13, ANSWER: A quadriphonic cable]

### Elementary Signal Generators

So far we have seen the wire and the cut primitives as well as two composition operators: 
the parallel composition and the sequential composition. Let's see now some signal generator primitives,
that is audio circuits with no input signals. 

#### Numbers

Numbers in Faust are signal generators. A Faust number produces an output signal whose 
samples are all equal to that number starting from time 0.

[SLIDE 14: Numbers are signal Generators] 

Note that the values of the samples of the signal produced by the number 1 in 
Faust are all 0 before time 0. 

#### User Interface elements
User Interface elements like _buttons_, _checkbox_ and _sliders_ are also elementary signal generators. 
They all generate a signal according to user's actions.

A button generates a signal that is 0 when the button is not pressed and that is 1 while the button 
is pressed. Similarly, a checkbox generate a signal that is 0 when the checkbox is not checked and 
that is 1 while the checkbox is checked.

[SLIDE 15: UI widgets]

A slider delivers a signal that ranges between a minimum and a maximum value. It has five parameters:
- The first one is the name of the slider as it is going to appear on the user interface, here "level".
- The second one is the default value of the slider, the value that it delivers when the program starts,
here it is 0.1. 
- The third parameter is the minimum value, the lowest value the slider can deliver, 
here 0.
- The fourth one is the maximum value, the highest value the slider can deliver, here 1. 
- The fifth and last parameters is a step value, here 0.1.

There are two kind of sliders:
- hslider is an horizontal slider
- vslider is a vertical slider

You can somehow listen to the sound produced by a slider:

```
process = vslider("level", 0, -1, 1, 0.01);
```



### Arithmetic

All standard arithmetic operations on numbers exist in Faust as operations on signals.

[Slide 16: Arithmetic Operations]

For instance, signals can be summed, subtracted, multiplied, raised to the 
power, divided, take the modulo of one signal by the other.

As an example let's do a simple _volume control_ by assembling three primitives: a wire, 
a vertical slider and a multiplication.

```
process = _, vslider("level", 0, 0, 1, 0.01) : * ;
```

We use the parallel composition to combine the wire and the slider. The resulting circuit 
has two output signals. It can therefore be connected to a multiplier using the sequential composition 
operator `:`. 

### Core Notation vs Infix Notation
Let say that we would like to express our level control as a value between 0 and 100, instead of 0 and 1. 
We will have to scale down the signal produced by the slider by 100.

```
process = _, (vslider("level", 0, 0, 100, 1), 100 : /) : * ;
```


### infix notation and syntactic sugar
What about doing a simple multiplication between to numbers? Let's say 2 and 3. Here is the Faust program to write:

```
process = 2, 3 : * ;
```
Sometimes it is more convenient to use the usual infix notation:

```
process = 2*3;
```

But this is just syntactic sugar for the core notation 



### Comparison

All standard comparison operations on numbers are available in Faust.
But there is an important difference between comparing numbers and signals. 
If we compare two numbers the result is either true or false. 

But what happen when we compare two signals that evolves in time ? 
The result is no more simply true or false, but will evolves in time according to the
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

```
import("stdfaust.lib");
process = os.oscsin(10), vslider("threshold", 0, 0, 1, 0.01) : >;
```
When the threshold is 0, the condition is true during half the period and false during the
other half. The signal produced is a square wave in the range 0,1.

When we increase the threshold the portion of samples at 1 will shrink until the 
threshold reach one. In this case the condition is always false and the signal produced is 
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

```
phasor(f) = f/44100 : (+,1:fmod) ~_;
process = phasor(440) * 6.28318530718 : sin;
```

We start by defining a `phasor`, a phase generator that produces a periodic sawtooth signal of frequency f. Then we multiply the output signal by `2 PI`  and take the sine.

### Log and Exponential

Bla bla

[Slide 23: Log and Exponential]

Bla bla

### Min, Max and other functions

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

```
gain = hslider("gain",0.05,0,1,0.01);
process = *(100) : min(1) : max(-1) : *(gain);
```

The input signal is first multiplied by a 100 which corresponds to the drive 
parameter of the distortion. Then we hard-clip it between -1 and 1 using the
min and max primitives in series. It might seem counter-intuitive to use 1 with
min and -1 with max but that's right thing to do. Indeed, we want the minimum 
value between 1 and the input signal in order for the output signal to not 
exceed 1. Similarly, we want the maximum value between -1 and the input signal 
in order for the output signal to not be inferior to -1. 
