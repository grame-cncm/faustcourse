
## Lesson 2: Basic Faust Primitives

In this lesson, we're going to look at most of Faust's primitives which are
built-in functions of the language. You can think of these primitives as
elementary audio circuits. For example the Faust primitive `+` is an audio
circuit with two input signals and one output signal.

As you will discover, programming in Faust is essentially composing audio
circuits together to build more complex ones. To compose these circuits we
use a set of five composition operators: parallel composition, sequential
composition, split composition, merge composition and recursive composition.
We will present in greater details these composition operations in lesson 6.

### Signals and Time Models

Before going into the details of all the primitives, let's first describe
what are the signals that our audio circuits will manipulate.

[Slide 8: Signals and Time model]

Informally, a signal is a value that changes over time, for example the
variation of air pressure producing a sound. In other words, a signal is a
function transforming a time input into a value output. This value is
also called a sample.

By convention, the full scale audio range for samples is typically a floating-point value
between -1 and +1. But of course, Faust can manipulate signals of arbitrary
ranges that can also be integer signals.



If we give a name to this signal for example s, then s(t) represents the
value of the signal s at time t.

Now let's define time more precisely. Since we are interested in sampled
signals (also called discrete signal), here time is an integer. A signal is
infinite both in the future and in the past but the value of time is 0 when the
Faust program starts. (a revoir)


### Wire
Let start with the simplest primitive you can think of: the _wire_. The Faust name
for a wire is `_` underscore, because somehow it looks like a wire !

Let's write a FAUST program that uses a wire to connect the audio input to the audio output:

```
process = _;
```

Before running this program, make sure that you set the audio level to the
minimum. Otherwise, you may damage your loudspeakers, or worse, your ears!

Now that you have set the audio volume to 0, start the program and increase
very slowly the volume to stay at the limit of hearing feedback.

So what is the semantics of `_` ? (Remember that _semantics_ is just a fancy
word for _meaning_). It is the _identity function_. The output signal
produced by underscore is the same/identical as the input signal. In other words
underscore is a _perfect_ wire that doesn't introduce any modification to
the input signal.

[SLIDE 9]

The slide explains the meaning of underscore in more mathematical terms. Lets
call `x(t)` the input signal of underscore and `y(t)` the output signal. We can
express the meaning of underscore by saying that `y(t)=x(t)`.

Let say now that we want to create a stereo cable made of two wires.
How can we place two circuits in parallel ?

[SLIDE 10: A cable made of two wires]

For that, we use the _parallel composition_ operator represented by the `,`
(comma) sign.

### Cut
The primitive Cut, represented by the exclamation mark (`!`) can be used to cut-out a
signal that we don't want to use.

Let say that we have a stereo signal and that we want to keep only the right channel.
We can easily do that by placing in parallel a cut for the left channel and a wire for
the right channel as in the following example:

```
process = !,_;
```

[SLIDE 11: Keep only the right channel of a stereo cable]

[QUIZ]
Write a Faust program that represents a quadraphonic cable

[SLIDE 12, QUIZ: A quadraphonic cable ?]

```
process = _,_,_,_;
```
[SLIDE 13, ANSWER: A quadraphonic cable]

### Elementary Signal Generators

So far we have seen the wire and the cut primitives as well as two composition operators:
the parallel composition and the sequential composition.

Let's see now some signal generator primitives: that is audio circuits with no input signals and one output signal.

#### Numbers

Numbers in Faust are signal generators. A Faust number produces an output signal whose
samples are all equal to that number starting from time 0.

[SLIDE 14: Numbers are signal Generators]

Note that the values of the samples of the signal produced by the number 1 in
Faust are all 0 before time 0.

#### User Interface elements
[SLIDE 15: UI widgets]
User Interface elements like _buttons_, _checkbox_ and _sliders_ are also elementary signal generators.
They all generate a signal according to user's actions.

A button generates a signal that is 0 when the button is not pressed and that is 1 while the button
is pressed. Similarly, a checkbox generate a signal that is 0 when the checkbox is not checked and
that is 1 while the checkbox is checked.



A slider delivers a signal that ranges between a minimum and a maximum value. It has five parameters:
- The first one is the name of the slider as it is going to appear on the user interface, here "level".
- The second one is the default value of the slider which is the value that it delivers when the program starts,
here it is 0.1.
- The third parameter is the minimum value which is the lowest value the slider can deliver,
here 0.
- The fourth one is the maximum value which is the highest value the slider can deliver, here 1.
- The fifth and last parameters is a step value, here 0.1.

There are two kind of sliders:
- hslider is an horizontal slider
- vslider is a vertical slider

You can somehow listen to the sound produced by a slider (explain its artifact):

```
process = vslider("level", 0, -1, 1, 0.01);
```
