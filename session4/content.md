# Session 4: Sound Synthesis and Processing II

In this session, we're going to continue the work that we started in session 3
and we're going to implement a few more sound processing algorithms in Faust.
For instance, we'll start with a simple feedforward filter, we'll then exploit
a feedback delay loop to implement a feedback comb filter, an echo, and a 
virtual string also know as Karplus-Strong. We'll also make a simple
granular synthesizer. Finally, we'll end the session by having a quick look at 
the content of the Faust signal processing libraries.  

## Lesson 1: Feedforward (One Zero) Filter

One of the strength of Faust is its conciseness. As we'll see in the 2 
following lessons, filters can be implemented in Faust with just a few lines
of code or even just a few characters in some cases.

In this lesson, we'll start with the one zero filter (or feedforward filter)
which can be implemented simply by adding a signal to its delayed version by
one sample. 

[show slide 1]

More theory around this type of filter is available in the corresponding
section of Julius Smith's online book: 
<https://ccrma.stanford.edu/~jos/fp/One_Zero.html>

Let's review what we need here: we must be able to split the signal, add it
(or merge it), and delay a signal by one sample which can be done using the
apostrophe.

[show screen capture: code]

```
oneZero = _ <: _',_ :> _;
``` 

We can create a `oneZero` circuit by taking an input signal, splitting it into 
a signal and its delayed version by one sample, and merging these 2 signals
together.

In that case, the signal going through this filter will be lowpass-filtered.
The main parameter (or coefficient) of this type of filter is its zero (also 
called "b1") which is just a number between -1 and 1 that will get multiplied
to the delayed signal in our filter circuit.

[show screen capture: code]

```
import("stdfaust.lib");
oneZero = vgroup("One Zero Filter",_ <: (_' : *(b1)),_ :> _) 
with{
	b1 = hslider("b1",0,-1,1,0.01);
};
process = oneZero;
```

We can assign a user interface element to control this parameter in our 
`oneZero` circuit and we can encapsulate its content into a group to have its 
name appear in the corresponding user interface.

[show screen capture: code]

```
import("stdfaust.lib");
oneZero = vgroup("One Zero Filter",_ <: (_' : *(b1)),_ :> _) 
with{
	b1 = hslider("b1",0,-1,1,0.01);
};
process = no.noise : oneZero;
```

We can connect a white noise generator to our `oneZero` circuit to see if it
works. 

[show screen capture: run the code and spectrogram]

As expected, you can see that when `b1` is negative, `oneZero` acts as a 
highpass filter and when `b1` is positive, it acts as a lowpass.

Once again, if you're curious about the theory behind this type of filter and 
how they work, we recommend you to check the corresponding section in Julius 
Smith's online book on filter design: 
<https://ccrma.stanford.edu/~jos/fp/One_Zero.html>.

## Lesson 2: Feedback Comb Filter

In the next three lessons, we'll explore various versions of the same algorithm
using feedback to implement a feedback comb filter, an echo effect, and finally 
a simple string physical model also known as the Karplus-Strong algorithm.

In this lesson, we'll focus on the implementation of a feedback comb filter.

[show slide 2]

More theory around this type of filter is available in the corresponding
section of Julius Smith's online book: 
<https://ccrma.stanford.edu/~jos/pasp/Feedback_Comb_Filters.html>

Implementing this algorithm in Faust is straight forward and can be done in
one line with just a few characters. Let's review what we need here: we must
create feedback, which can be done with the tilde in Faust, and we have to add
a delay of an arbitrary number of samples, which can be done using the `@`.
Let's create a `fComb` circuit for this.

[show screen capture: code]

```
import("stdfaust.lib");
fComb = +~(@(delLength) : *(feedback))
with{
  delLength = hslider("Delay Length",1,1,100,1);
  feedback = hslider("Feedback",0,0,1,0.01);
};
process = fComb;
```

Before we explain this code, let's plot its corresponding block diagram.

[put the diagram next to the code]

We can see that the tilde takes care of splitting the signal and of creating 
the feedback. Any expression on the right hand side of tilde is placed in the 
feedback signal. The feedback signal connects to the first available input it 
finds in the circuit which is one of the 2 inputs of the add primitive. The 
other input of the add becomes an input of the `fComb` circuit. As Yann 
explained in session 2, you should keep in mind that an implicit one sample
delay is introduced when using the tilde.

We can also assign user interface elements to control the parameters of our 
filter as we did for previous examples.

[show screen capture: code]

```
import("stdfaust.lib");
fComb = vgroup("Feedback Comb Filter",+~(@(delLength-1) : *(feedback)))
with{
  delLength = hslider("[0]Delay Length",1,1,100,1);
  feedback = hslider("[1]Feedback",0,0,1,0.01);
};
process = fComb;
```

Adding a few more user interface elements, we can create a nice feedback
comb filter plugin!

[show screen capture: code]

```
import("stdfaust.lib");
fComb = vgroup("Feedback Comb Filter",+~(@(delLength-1) : *(feedback)))
with{
  delLength = hslider("[0]Delay Length",1,1,100,1);
  feedback = hslider("[1]Feedback",0,0,1,0.01);
};
process = no.noise : fComb;
```

Let's now feed some white noise to our `fComb` circuit to see if it works. 

[show screen capture: run the code and plot the spectrum]

Note that `fComb` could be easily used to implement a flanger effect by 
modulating the length of our delay using an LFO. As an exercise, you should
try to do this now.

[show screen capture: code]

```
import("stdfaust.lib");
fComb = vgroup("Feedback Comb Filter",+~(de.fdelay4(maxDelay,delLength) : *(feedback)))
with{
  maxDelay = 10;
  freq = hslider("Frequency",1,0.1,10,0.01);
  feedback = hslider("[1]Feedback",0,0,1,0.01);
  delLength = (maxDelay-1)*(os.osc(freq)*0.5+0.5);
};
process = no.noise : fComb;
```

The delay is now oscillating between 1 and `maxDelay` at a frequency defined
by the `Frequency` slider. Note that we're now using a fractional delay that
is available in the `delays.lib` library and built on top of `@`.

Once again, if you're curious about the theory behind this type of filter and 
how they work, we recommend you to check the corresponding section in Julius
Smith's online book on filter design: 
<https://ccrma.stanford.edu/~jos/fp/One_Zero.html>.

## Lesson 3: Echo 

In the previous lesson, we implemented a feedback comb filter. This circuit
can be slightly modified to implement an echo effect essentially by controlling
the length of the delay line as a duration in ms instead of number of samples 
and also by allowing the use of longer delays.

A duration in seconds can be easily converted to a number of samples by
multiplying this duration by the sampling rate. Sampling rate can be retrieved
in Faust by calling the `ma.SR` variable which is declared in `maths.lib`.  

[show screen capture: code]

```
import("stdfaust.lib");
echo = vgroup("Echo",+~(@(delLength-1) : *(feedback)))
with{
  duration = hslider("[0]Duration",500,1,1000,1)*0.001;
  feedback = hslider("[1]Feedback",0.5,0,1,0.01);
  delLength = ma.SR*duration;
};
process = echo;
```

We can reuse the code from the previous lesson and rename the `fComb` circuit 
`echo`. The `Delay Length` slider can be replaced by a `Duration` slider whose
value will be set in milliseconds. To convert this signal in seconds (which will
be needed for the next step), we can multiply it by 0.001. The signal produced 
by this slider and converted in seconds can be used to compute the length of 
our delay line by multiplying it by the sampling rate.

We just implemented an echo effect, try to run have fun with it! Be careful
with feedback!

## Lesson 4: Karplus-Strong

In the two previous lessons, we used the same circuit to implement a feedback
comb filter and an echo effect. In this lesson, we're going to use this circuit
again to implement a simple string synthesizer known as the Karplus-Strong
algorithm. 

When playing around with the feedback comb filter implemented in lesson 2,
you might have noticed that for certain values of feedback and delay length,
the generated sound sounds like a plucked string. That's because a string can
be thought of a closed loop where the energy traveling in the string is
reflected at its termination with some damping.

If you want to know more about the theory behind this type of algorithm, you
can read the corresponding section in Julius Smith's online book: 
<https://ccrma.stanford.edu/~jos/pasp/Karplus_Strong_Algorithm.html>.

To implement our Karplus-Strong circuit, we can reuse our `fComb` circuit from
lesson 1 and rename it `string`.

[show screen capture: code]

```
import("stdfaust.lib");
string = vgroup("String",+~(@(delLength-1) : *(feedback)))
with{
  delLength = hslider("[0]Delay Length",1,1,100,1);
  feedback = hslider("[1]Feedback",0,0,1,0.01);
};
process = fComb;
``` 

The length of the delay will determine the length of the string we're 
implementing and therefore its pitch. So we first want to replace our 
`Delay Length` slider by a MIDI-controllable `freq` slider. 

[show screen capture: code]

```
import("stdfaust.lib");
string = vgroup("String",+~(@(delLength-1) : *(damping)))
with{
  freq = hslider("[0]freq",440,50,5000,1);
  damping = hslider("[1]Damping",0.99,0,1,0.01);
  delLength = ma.SR/freq;
};
```

Frequency can be easily converted to a number of samples simply by dividing the 
sampling rate by the frequency. 

The feedback of the delayed loop will control the damping of the string. The
closer the value of feedback will be to 1, the longer the string will vibrate.
Let's rename our `feedback` parameter `damping` and let's give it a default
value of 0.99 which is a good value to implement a free vibrating string.

In order to make sound, strings need to be plucked or bowed. We're now going
to implement a simple plucking circuit which just consists of generating an
impulse when a button is pressed. 

[show screen capture: code]

```
import("stdfaust.lib");
string = vgroup("String",+~(@(delLength-1) : *(damping)))
with{
  freq = hslider("[0]freq",440,50,5000,1);
  damping = hslider("[1]Damping",0.99,0,1,0.01);
  delLength = ma.SR/freq;
};
pluck = hgroup("[1]Pluck",gate : ba.impulsify*gain)
with{
  gain = hslider("gain",1,0,1,0.01);
  gate = button("gate");
};
process = pluck : string;
```

`basics.lib` contains a circuit named `ba.impulsify` that takes the signal from 
a button and turns into an impulse. Let's use it to make our plucking function 
that we can then connect to our string circuit in the `process` line. 

At this point, since our code declares `freq`, `gain`, and `gate`, it can be 
used as a polyphonic MIDI synthesizer: give it a try!

We can significantly improve the sound generated by this string circuit by
adding a dispersion filter to model the impact of the bridge and the nuts on
both sides of the string. Indeed, when energy in the string is absorbed by
these 2 elements, higher frequencies are damped faster than lower ones. 

[show screen capture: code]

```
import("stdfaust.lib");
string = vgroup("String",+~(@(delLength-1) : dispersionFilter : *(damping)))
with{
  freq = hslider("[0]freq",440,50,5000,1);
  damping = hslider("[1]Damping",0.99,0,1,0.01);
  dispersionFilter = _ <: _,_' :> /(2);
  delLength = ma.SR/freq;
};
pluck = hgroup("[1]Pluck",gate : ba.impulsify*gain)
with{
  gain = hslider("gain",1,0,1,0.01);
  gate = button("gate");
};
process = pluck : string;
```

Therefore, all we have to do is to add a lowpass filter to the delayed loop of
our string. The Karplus-Strong algorithm typically uses a feedforward filter
very similar to the one implemented in lesson 1. Note that we're diving its
gain by 2 to preserve stability in the loop. 

[show screen capture: run the code]

As you can see, things sound much better now. 

A final improvement we can make is related to the precision of pitch. 
Indeed, you might have noticed that our string is slightly out of tune and 
that this problem increases as we
generate notes with a higher frequency. That's due to the use of an integer
delay with the `@` primitive. Since delay can only be expressed as an integer
using the `@`, our string circuit will suffer from a lack of precision, 
especially as we'll decrease the length of our delay. This problem can be
easily solved by using fractional delay which will allow for the use of 
decimal values for our delay length. 

`de.fdelay4` implements a fractional delay
using 4th order Lagrange interpolation. It is ideal for what we're trying to
achieve here. Fractional delay is a pretty hairy topic but if you're interested
to learn more about the theory behind it, you can check the related section in
Julius Smith' online book: 
<https://ccrma.stanford.edu/~jos/pasp/Fractional_Delay_Filtering_Linear.html>.

[show screen capture: code]

```
import("stdfaust.lib");
string = hgroup("String[0]",+~(de.fdelay4(maxDelLength,delLength-1) : dispersionFilter : *(damping)))
with{
  freq = hslider("[0]freq",440,50,5000,1);
  damping = hslider("[1]Damping[style:knob]",0.99,0,1,0.01);
  maxDelLength = 1024;
  dispersionFilter = _ <: _,_' :> /(2);
  delLength = ma.SR/freq;
};
pluck = hgroup("[1]Pluck",gate : ba.impulsify*gain)
with{
  gain = hslider("gain[style:knob]",1,0,1,0.01);
  gate = button("gate");
};
process = vgroup("Karplus Strong",pluck : string);
```

The `de.fdelay4` circuit requires to set a maximum delay length as a number of
samples. Since the lowest frequency of our string is set to be 50Hz, the 
maximum length of the delay at a sampling rate of 48KHz will be 960, so the 
maximum delay length should be at least this value. 

Note the we made a few cosmetic modifications to the interface of our 
instrument to make it look better.   

In case you're interested, the Faust distribution hosts a library to implement 
physical models of musical instruments. Its documentation can be found in the 
libraries doc.

[show URL: <http://faust.grame.fr/library.html#physmodels.lib>]

## Lesson 5: Sampling and Simple Granular Synthesis

In this final lesson, we're going to use a wavetable to implement a highly
simplified form of granular synthesis. It will demonstrates the use of 
read/write tables in Faust while providing a fun sound synthesizer.

As seen in session 2, the `rwtable` primitive implements a
table that can be read and written in real-time. It has 5 inputs (TODO: may be
link to doc): the table size, the value of the initial sample, the write index
(which should be an integer), the main signal input, and the read index (which
should also be an integer). 

In this first step, we want to create a `looper` circuit taking an input, 
recording it in a table when a button is pressed, and then looping it at a
certain speed.  

[show screen capture: code]

```
import("stdfaust.lib");
looper = rwtable(tablesize,0.0,recIndex,_,readIndex)
with{
  record = button("[2]Record") : int;
  readSpeed = hslider("[0]Read Speed",1,0.001,10,0.01);
  tablesize = 48000;
  recIndex = +(1)~*(record) : %(tablesize);
  readIndex = readSpeed/float(ma.SR) : (+ : ma.decimal) ~ _ : *(float(tablesize)) : int;
};
process = looper;
```

We want the maximum length of the table to be around 1 second so we're going
to set it to 48000. We also want the table to not output any signal when the
program start so we're going to set the second input which is the 
initialization signal of our `rwtable`.

We want the write index to be always 0 when the record button is not pressed
and start counting one by one when the button is pressed. 

Here `record` is the output of the record button. Since
`recIndex` might exceed the size of the table which would create a segfault:
not good! We're using a modulo operation to wrap the value of the counter when 
it reaches the table size which loops the recording of the input in the table.

For the read index, we essentially want to implement a phasor whose value will
range between 0 and the table size. Also, since we want to be able to control
the read speed, we should be able to change the frequency of this phasor by 
modifying its increment value. This phasor should constantly read through the
table right from when the program starts. 

Note that the read and write indices are casted to int to satisfy the 
requirements of the `rwtable`. Try to run it and have fun!

[show screen capture: run the code and play with it]

To conclude this lesson, we're now going to put multiple `looper` circuit in
parallel to create complex dense sound textures. This can be easily done by
using the `par` primitive. 

[show screen capture: code]

```
import("stdfaust.lib");
looper(detune) = rwtable(tablesize,0.0,recIndex,_,readIndex)
with{
  record = button("[2]Record") : int;
  readSpeed = hslider("[0]Read Speed",1,0.001,10,0.01);
  tablesize = 48000;
  recIndex = +(1)~*(record) : %(tablesize);
  readIndex = readSpeed*(detune+1)/float(ma.SR) : (+ : ma.decimal) ~ _ : *(float(tablesize)) : int;
};
polyLooper = vgroup("Looper",_ <: par(i,nVoices,looper(detune*i)) :> _,_)
with{
  nVoices = 10;
  detune = hslider("Detune",0.01,0,1,0.01);
};
process = polyLooper : dm.zita_light;
```

We don't want each version of the looper to be the same. Instead, we want each
looper to have a slightly different read speed so we're adding a `detune`
parameter to our `looper` circuit that will be used as a ratio to control the
read speed,

We created a `polyLooper` circuit putting several `looper` in
parallel. We can use the counter index of the `par` primitive to control the
value of detune. Finally, we created a new parameter controlled by a user
interface element to control the amount of speed offset/detuning between the
various instances of our `looper`. 

To make a nicely polished version of this program, we also added a light stereo
reverb to it using the `dm.zita_light` circuit.

Note that we merged the 10 parallel `looper`s into 2 signals to create a nice
stereo effect.

Have fun!

[show screen capture: run the code]

## Lesson 6: Quick Tour of the Libraries

Done on the spot. 
