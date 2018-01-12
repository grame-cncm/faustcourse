# Session 4: Sound Synthesis and Processing I

Welcome to this new session on sound processing in Faust! Here, we're going to
implement a series of sound synthesizers and audio effects ready to be turned
into audio plug-ins, smartphone apps, and more. We'll study the math behind 
various algorithms as well as their implementation from scratch in Faust. We'll
also spend a fair amount of time designing polished interfaces. We'll start 
with simple sound synthesis techniques such as waveshape, amplitude modulation,
frequency modulation, and subtractive synthesis. We'll then TODO: finish in
function of what you had time to talk about. 

As for the previous sessions, all the code we're going to write here is
optimized to work in the Faust online editor (<https://faust.grame.fr/editor>).

TODO: may be more

TODO: perhaps explain that since we have a limited amount of time, we don't
detail the algorithms too much and that we just look at their implementation.

## Lesson 1: Waveshape Synthesis

In this lesson, we use waveshape synthesis to implement a polyphonic MIDI 
synthesizer where the user can choose between a series of waveform like
sine, triangle, square, and sawtooth to generate sound. 

Waveshape synthesis (which might also be called wavetable synthesis under
certain conditions) is probably the easiest kind of sound synthesis. It 
consists of generating a sound by periodically repeating a single-cycle 
waveform. (TODO: link to session 2) The speed at which the waveform will be 
repeated will determine its period and hence its frequency. 

While any waveform can be used, standard waveforms inherited from analog 
synthesis are commonly used in the digital world. Most of you probably already 
know them but let's quickly refresh your mind. 

[Example 1: on the screen, show the waveform, the corresponding compiled Faust
program, and the real time spectrum analyzer (e.g., baudline) and comment
each waveform as follows.]

A sinusoid will generate a pure tone. A square wave will generate a complex
sound containing only odd-integer harmonics. A triangle wave will also only
generate odd harmonics, however, higher harmonics roll off much faster than 
in a square wave giving it a much smoother timbre. A sawtooth wave will
generate a complex sound containing all integer harmonics.

Various oscillator circuits to generate this type of waveforms are available in 
`oscillators.lib`, which is the oscillators library in Faust. The most standard
ones are `os.osc()` for the sine wave, `os.square()` for the square wave,
`os.triangle()` for the triangle wave, and `os.sawtooth()` for the sawtooth
wave.

All these oscillators are band-limited which means that they're aliasing-free,
as long as they are used within a certain range. [TODO: may be add a link
explaining what aliasing is]. While we really want to prevent aliasing when
generating this type of sound, the main drawback is that these oscillators
will probably not work properly if they are used under a certain frequency.
For instance, except for `os.osc` which is naturally band
limited, `os.square`, `os.sawtooth`, `os.triangle` could not be used as Low
Frequency Oscillators (LFO). We'll get back to this later in this session 
when we use an LFO to modulate the cutoff frequency of the filter of a 
subtractive synthesizer.   

First, let's create a `waveGenerator` circuit where our oscillators are placed
in parallel and selected using the `selectn` circuit from `basics.lib`. Note
that `selectn` is a generalized version of the `select2` primitive studied in
session 2 (TODO: make sure it was actually studied). 

We integrate user interface elements to our circuit to select the frequency of 
the oscillators with a slider and the waveform with a numerical entry. Note 
that we're using the standard MIDI parameter name `freq` for the frequency 
here. That way, when we turn our synthesizer into a polyphonic MIDI instrument,
its frequency will be automatically controlled by the pitch of the desired note.

Let's call the waveGenerator circuit in the process line of our Faust program
and let's run it to see if it works.

```
import("stdfaust.lib");
waveGenerator = os.osc(freq),os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave)
with{
  wave = nentry("Waveform",0,0,3,1);
  freq = hslider("freq",440,50,2000,0.01);
};
process = waveGenerator;
``` 

In order for our wave generator to be used as a MIDI polyphonic synthesizer,
we must add an envelope generator to it to trigger sounds when note on 
messages are received. As you probably already know, there exists a wide range
of envelope generators and the most famous and broadly one is the ADSR. 

[slide 2: ADSR envelope]

Just as a quick refresher, ADSR envelope generators have 4 phases [show on the
slide]: the attack, the decay, the sustain, and the release. That's why they're
called ADSR! 

The envelope library of Faust called `envelopes.lib` contains a circuit 
implementing an ADSR envelope generator: `en.adsr`. It will output a signal
whose range is 0 to 1 where 0 corresponds to the beginning of the attack and
the end of the release and where 1 is reached at the end of the attack, right
before the decay. This means that the output of `en.adsr` will have to be 
scaled by any potential gain parameter when implementing our MIDI synthesizer. 

As we can see it in the library documentation [show it!], this circuit has 5 
inputs: the duration of the attack in seconds, the duration of the decay in 
seconds, the percentage of the gain of the sustain in function of the maximum
gain reached after the attack, the duration of the release in seconds, and
finally a trigger signal, a `button` user interface element can be used for 
that.

As we did for our `waveGenerator` circuit, let's create an `envelope` circuit
hosting user interface elements to control the various parameters of `en.adsr`.

```
envelope = en.adsr(attack,decay,sustain,release,gate)*gain
with{
  attack = hslider("Attack",50,1,1000,1)*0.001;
  decay = hslider("Decay",50,1,1000,1)*0.001;
  sustain = hslider("Sustain",80,1,100,1);
  release = hslider("Release",50,1,1000,1)*0.001;
  gain = hslider("gain",1,0,1,0.01);
  gate = button("gate");
};
```

We're using milliseconds as our time unit as it is more practical than seconds
in this scenario. Note that we used the standard MIDI user interface elements
name here as we did for the `freq` parameter for our `waveGenerator` circuit. 
Note that the signal generated by our `gain` slider is multiplied to the output 
of the envelope generator.  

Let's put this together in the `process` line by multiplying our `waveGenerator`
and `envelope` circuit together:

```
import("stdfaust.lib");
waveGenerator = os.osc(freq),os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave)
with{
  wave = nentry("Waveform",0,0,3,1);
  freq = hslider("freq",440,50,2000,0.01);
};
envelope = en.adsr(attack,decay,sustain,release,gate)*gain
with{
  attack = hslider("Attack",50,1,1000,1)*0.001;
  decay = hslider("Decay",50,1,1000,1)*0.001;
  sustain = hslider("Sustain",80,1,100,1);
  release = hslider("Release",50,1,1000,1)*0.001;
  gain = hslider("gain",1,0,1,0.01);
  gate = button("gate");
};
process = waveGenerator*envelope;
```

At this point, if you're using Google Chrome as we suggested (remember that as
of today, only this browser is compatible with MIDI) and activate the MIDI
polyphonic mode, you're Faust code should become controllable by an virtual
or physical MIDI keyboard connected to your computer! [do it!]

To finish this lesson, let's try to improve the user interface of our 
synthesizer by organizing its various elements and by changing their appearance.
First, let's create a `Synth` vertical group encapsulating the entire interface.
Then, let's use knobs for our envelope generator parameters by declaring the
`[style:knob]` metadata in the name of the user interface elements (TODO:
might want a link to the doc here). 

Placing knobs horizontally will help save space in the interface. For that we 
can create a `Envelope` horizontal group encapsulating the various elements of
the envelope generator. We should also number the user interface elements 
withing this group to make sure they appear in the right order in the interface. 
Finally, let's do the same for our wave generator.

Run the code and try to control with a MIDI keyboard as we did in previous
sessions.

```
import("stdfaust.lib");
waveGenerator = hgroup("[0]Wave Generator",os.osc(freq),os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave))
with{
  wave = nentry("[0]Waveform",0,0,3,1);
  freq = hslider("[1]freq",440,50,2000,0.01);
};
envelope = hgroup("[1]Envelope",en.adsr(attack,decay,sustain,release,gate)*gain)
with{
  attack = hslider("[0]Attack[style:knob]",50,1,1000,1)*0.001;
  decay = hslider("[1]Decay[style:knob]",50,1,1000,1)*0.001;
  sustain = hslider("[2]Sustain[style:knob]",80,1,100,1);
  release = hslider("[3]Release[style:knob]",50,1,1000,1)*0.001;
  gain = hslider("[4]gain[style:knob]",1,0,1,0.01);
  gate = button("[5]gate");
};
process = vgroup("Synth",waveGenerator*envelope);
```

You probably noticed that if multiple keys are pressed at the same time, the
generated sound is clicking. That's because the voices instantiated when
pressing the keys all add up without being scaled. To fix the problem, the
output of the envelope generator can be multiplied by a static number. Here
we choose 0.3:

```
import("stdfaust.lib");
waveGenerator = hgroup("[0]Wave Generator",os.osc(freq),os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave))
with{
  wave = nentry("[0]Waveform",0,0,3,1);
  freq = hslider("[1]freq",440,50,2000,0.01);
};
envelope = hgroup("[1]Envelope",en.adsr(attack,decay,sustain,release,gate)*gain*0.3)
with{
  attack = hslider("[0]Attack[style:knob]",50,1,1000,1)*0.001;
  decay = hslider("[1]Decay[style:knob]",50,1,1000,1)*0.001;
  sustain = hslider("[2]Sustain[style:knob]",80,1,100,1);
  release = hslider("[3]Release[style:knob]",50,1,1000,1)*0.001;
  gain = hslider("[4]gain[style:knob]",1,0,1,0.01);
  gate = button("[5]gate");
};
process = vgroup("Synth",waveGenerator*envelope);
```

## Amplitude Modulation

TODO

Amplitude modulation consists of modulating the amplitude of a signal called 
the carrier with the signal of an oscillator called the modulator. Typically,
the modulator is implemented with a sine wave oscillator but other types of
oscillators can be used. 

Amplitude modulation can be used as an audio effect when processing sounds from
the "real-world" but also as a sounds synthesis techniques when the carrier is
also generated by an oscillator.

In this lesson, we'll study this special case of amplitude modulation where
both the carrier and the modulator are implemented using sine wave oscillators.

[Slide 2: AM algorithm]

We'll look at the spectrum of the sound generated by this type of synthesizer 
later in this lesson but for now, let's implement our amplitude modulation 
synthesizer. All we want to do here is to multiply a sine wave oscillator by 
another one. Let's create a circuit for that involving hosting user interface
elements to control of the frequency of the 2 oscillators:

```
am = carrier*modulator
with{
  carrier = os.osc(carFreq);
  modulator = os.osc(modFreq);
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  carFreq = hslider("Carrier Frequency",440,50,2000,0.01);
};
```

[Slide 3: LFO range]

Even though calling `am` in the process line will work and generate sound, it
doesn't do exactly what we want. Indeed, the range of the modulator is 
currently -1 to 1, which means that the gain of the carrier goes from 0 to 1,
then 1 to 0, then 0 to -1, and finally -1 to 0 at every period. In other words,
the current modulation frequency is doubled and a phase inversion happens twice
per period. Instead, we want the modulator to go from 0 to 1 and then back to 
at every period.

This can be easily fixed by scaling the output of the modulator to make sure
that it's range is between 0 and 1:

```
am = carrier*modulator
with{
  carrier = os.osc(carFreq);
  modulator = os.osc(modFreq)*0.5 + 0.5;
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  carFreq = hslider("Carrier Frequency",440,50,2000,0.01);
};
``` 

We now want to be able to control the "depth" of the modulation which 
corresponds to the amount of modulation applied to the sound. Scaling the gain
of our modulator with a depth parameter will not be enough as if depth is 0,
no sound will be generated as the gain of `modulator` which is currently
multiplied to `carrier` will be 0 as well. Thus, we need to compensate for the
value of depth by adding 1 to the modulator such that:

```
am = carrier*modulator
with{
  carrier = os.osc(carFreq);
  modulator = ((1-modDepth) + (os.osc(modFreq)*0.5+0.5)*modDepth);
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  carFreq = hslider("Carrier Frequency",440,50,2000,0.01);
  modDepth = hslider("Modulator Depth",0.5,0,1,0.01);
};
```

Let's try to call `am` in the process line and see how this sounds.

If we look at the spectrogram of the generated sound [do it], we can see that 
it contains three harmonics: the carrier frequency, at the middle, and 
sidebands on both side of the carrier.

[Slide 4: AM spectrum]

The frequency of the left side band is equal to the frequency of the carrier
minus the frequency of the modulator and the the frequency of the right side
band is equal to the frequency of the carrier plus the frequency of the
modulator. The gain of the carrier is half its original value and the gain of
the sidebands is a 1/4 of the original carrier gain.

We can now reuse the `envelope` circuit from lesson 2 to turn `am` into a
polyphonic synthesizer. Also, in order for the frequency of the synth to be
controlled with MIDI, we must rename our `Carrier Frequency` parameter to
`freq`. After some cleaning, our code should now look like:

```
import("stdfaust.lib");
am = hgroup("[0]AM",carrier*modulator)
with{
  carrier = os.osc(carFreq);
  modulator = ((1-modDepth) + (os.osc(modFreq)*0.5+0.5)*modDepth);
  modFreq = hslider("[0]Modulator Frequency[style:knob]",20,0.1,2000,0.01);
  modDepth = hslider("[1]Modulator Depth[style:knob]",0.5,0,1,0.01);
  carFreq = hslider("[2]freq",440,50,2000,0.01);
};
envelope = hgroup("[1]Envelope",en.adsr(attack,decay,sustain,release,gate)*gain*0.3)
with{
  attack = hslider("[0]Attack[style:knob]",50,1,1000,1)*0.001;
  decay = hslider("[1]Decay[style:knob]",50,1,1000,1)*0.001;
  sustain = hslider("[2]Sustain[style:knob]",80,1,100,1);
  release = hslider("[3]Release[style:knob]",50,1,1000,1)*0.001;
  gain = hslider("[4]gain[style:knob]",1,0,1,0.01);
  gate = button("[5]gate");
};
process = vgroup("AM Synthesizer",am*envelope);
```

Run it and have fun playing!

Note that amplitude modulation works with any type of waveform and that 
triangle, sawtooth, or square waves from lesson 1 could be used here instead of 
sine waves and will likely produce richer sounds.

## Frequency Modulation

In the previous lesson, we modulated the amplitude of an oscillator by using
the signal of another one. In this lesson, we're going to modulate the 
frequency of an oscillator with another oscillator. This sound synthesis
method is called frequency modulation synthesis or FM. It allows for the
synthesis of sounds with a very rich complex spectrum. Here, we're going to
use it to make a polyphonic MIDI synthesizer.

Let's create an `fm` circuit where the frequency of a sine wave oscillator 
(the carrier) is modulated by another sine oscillator (the modulator):

```
fm = os.osc(carFreq + os.osc(modFreq)*index)
with{
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  index = hslider("Modulation Index",100,0,1000,0.01);
  carFreq = hslider("freq",440,50,2000,0.01);
};
```

The `Modulation Index` controls the amount of modulation applied to the
frequency of the carrier. Its range is unlimited. Note that we don't need to
scale the range of the modulator as we did in lesson 2 for amplitude modulation
as we want the frequency of the carrier to oscillate around a certain value,
which is defined here the `Modulator Frequency` slider. Note that we named the
slider controlling the carrier frequency `freq` since we want it to be controlled
by MIDI events, as we did in previous lessons.

Let's try to call this circuit in the `process` line and see what happens 
[do it]. 

[Example 3: FM spectrum]

As you can see, the spectrum of the generated sound is much denser than with
amplitude modulation and many more side bands are produced. 

Let's now use the `envelope` circuit from lesson 1 in this code to turn it
into a polyphonic MIDI synthesizer. After some cosmetic changes  to the
interface, our FM synthesizer should look like:

```
import("stdfaust.lib");
fm = hgroup("[0]FM",os.osc(carFreq + os.osc(modFreq)*index))
with{
  modFreq = hslider("[0]Modulator Frequency[style:knob]",20,0.1,2000,0.01);
  index = hslider("[1]Modulation Index[style:knob]",100,0,1000,0.01);
  carFreq = hslider("[2]freq",440,50,2000,0.01);
};
envelope = hgroup("[1]Envelope",en.adsr(attack,decay,sustain,release,gate)*gain*0.3)
with{
  attack = hslider("[0]Attack[style:knob]",50,1,1000,1)*0.001;
  decay = hslider("[1]Decay[style:knob]",50,1,1000,1)*0.001;
  sustain = hslider("[2]Sustain[style:knob]",80,1,100,1);
  release = hslider("[3]Release[style:knob]",50,1,1000,1)*0.001;
  gain = hslider("[4]gain[style:knob]",1,0,1,0.01);
  gate = button("[5]gate");
};
process = vgroup("FM Synthesizer",fm*envelope);	
```

Note that just like AM, FM works with any kind of oscillator and square wave,
sawtooth wave, or triangle wave oscillators could be used here instead of
sine waves.

OPTIONAL: harmonicity parameter instead of `freq`.

```
import("stdfaust.lib");
fm = hgroup("[0]FM",os.osc(carFreq + os.osc(carFreq*harmRatio)*index*harmRatio))
with{
  harmRatio = hslider("[0]Harmonicity Ratio[style:knob]",1,0,10,0.01);
  index = hslider("[1]Modulation Index[style:knob]",100,0,1000,0.01);
  carFreq = hslider("[2]freq",440,50,2000,0.01);
};
envelope = hgroup("[1]Envelope",en.adsr(attack,decay,sustain,release,gate)*gain*0.3)
with{
  attack = hslider("[0]Attack[style:knob]",50,1,1000,1)*0.001;
  decay = hslider("[1]Decay[style:knob]",50,1,1000,1)*0.001;
  sustain = hslider("[2]Sustain[style:knob]",80,1,100,1);
  release = hslider("[3]Release[style:knob]",50,1,1000,1)*0.001;
  gain = hslider("[4]gain[style:knob]",1,0,1,0.01);
  gate = button("[5]gate");
};
process = vgroup("FM Synthesizer",fm*envelope);	
```

## Subtractive

Subtractive synthesis consists of sculpting sound containing a dense harmonic
content such as noise, square waves, sawtooth waves, for example, using one
or several filters.

In this lesson, we're going to reuse the `waveGenerator` circuit implemented 
in lesson 1 as the source for our subtractive synthesizer. In practice, we
can even remove the sine wave oscillator from it since it doesn't make sense
to process a pure tone through a filter in this case, and we can replace it
with a white noise generator:

```
waveGenerator = hgroup("[0]Wave Generator",no.noise,os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave))
with{
  wave = nentry("[0]Waveform",3,0,3,1);
  freq = hslider("[1]freq",440,50,2000,0.01);
};
```

Let's now create a `subtractive` circuit taking `waveGenerator` and feeding it
in a resonant lowpass filter. This kind of filter is implemented in Faust in 
the `fi.resonlp()` circuit defined in the `filters.lib` filters library. As you
can see it in the libraries documentation [do it], this circuit has four inputs:
the cutoff frequency, the Q, the gain, and the signal to be processed. 

Here, in order to create a dynamic spectrum, we're going to modulate the cutoff
frequency of this filter using a low frequency sine wave oscillator. Since we
never want the cutoff frequency to be smaller or equal to zero, we need put a
safeguard here using `max`.

After we put this all together, adding user interface elements, our code should
look like this. Calling the `subtractive` circuit in the `process` line, we can
explore the potential of the various parameters of this synthesis technique.

Note that any kind of filter can be used here: highpass, bandpass and that they
can be daisy chained to create complex sounds and behaviors.

```
waveGenerator = hgroup("[0]Wave Generator",no.noise,os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave))
with{
  wave = nentry("[0]Waveform",3,0,3,1);
  freq = hslider("[1]freq",440,50,2000,0.01);
};
subtractive = waveGenerator : hgroup("[1]Filter",fi.resonlp(resFreq,q,1))
with{
  ctFreq = hslider("[0]Cutoff Frequency[style:knob]",2000,50,10000,0.1);
  q = hslider("[1]Q[style:knob]",5,1,30,0.1);
  lfoFreq = hslider("[2]LFO Frequency[style:knob]",10,0.1,20,0.01);
  lfoDepth = hslider("[3]LFO Depth[style:knob]",500,1,10000,1);
  resFreq = ctFreq + os.osc(lfoFreq)*lfoDepth : max(30);
};
```

Adding the `envelope` circuit form previous lessons we can implement a
polyphonic synthesizer simply by multiplying the output of `subtractive` by
`envelope`.

```
import("stdfaust.lib");
waveGenerator = hgroup("[0]Wave Generator",no.noise,os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave))
with{
  wave = nentry("[0]Waveform",3,0,3,1);
  freq = hslider("[1]freq",440,50,2000,0.01);
};
subtractive = waveGenerator : hgroup("[1]Filter",fi.resonlp(resFreq,q,1))
with{
  ctFreq = hslider("[0]Cutoff Frequency[style:knob]",2000,50,10000,0.1);
  q = hslider("[1]Q[style:knob]",5,1,30,0.1);
  lfoFreq = hslider("[2]LFO Frequency[style:knob]",10,0.1,20,0.01);
  lfoDepth = hslider("[3]LFO Depth[style:knob]",500,1,10000,1);
  resFreq = os.osc(lfoFreq)*lfoDepth + ctFreq : max(30);
};
envelope = hgroup("[2]Envelope",en.adsr(attack,decay,sustain,release,gate)*gain*0.3)
with{
  attack = hslider("[0]Attack[style:knob]",50,1,1000,1)*0.001;
  decay = hslider("[1]Decay[style:knob]",50,1,1000,1)*0.001;
  sustain = hslider("[2]Sustain[style:knob]",80,1,100,1);
  release = hslider("[3]Release[style:knob]",50,1,1000,1)*0.001;
  gain = hslider("[4]gain[style:knob]",1,0,1,0.01);
  gate = button("[5]gate");
};
process = vgroup("Subtractive Synthesizer",subtractive*envelope);
```

Run this code and have fun playing!

## Feedforward (One Zero) Filter

```
import("stdfaust.lib");
oneZero = vgroup("One Zero Filter",_ <: (_' : *(b1)),_ : +) 
with{
	b1 = hslider("b1",0,-1,1,0.01) : si.smoo;
};
process = oneZero;
```

## Feedback Comb Filter and Echo

```
import("stdfaust.lib");
fComb = vgroup("Feedback Comb Filter",+~(@(delLength) : *(feedback)))
with{
  delLength = hslider("[0]Delay Length",1,1,100,1);
  feedback = hslider("[1]Feedback",0,0,1,0.01) : si.smoo;
};
process = fComb;
```

## Echo 

```
import("stdfaust.lib");
fComb = vgroup("Echo",+~(@(delLength) : *(feedback)))
with{
  duration = hslider("[0]Duration",500,1,1000,1)*0.001;
  feedback = hslider("[1]Feedback",0.5,0,1,0.01) : si.smoo;
  delLength = ma.SR*duration;
};
process = fComb;
```

## Karplus

```
import("stdfaust.lib");
string = hgroup("String[0]",+~(de.fdelay4(maxDelLength,delLength) : dispersionFilter : *(damping)))
with{
  freq = hslider("[0]freq",440,50,5000,1);
  damping = hslider("[1]Damping[style:knob]",0.99,0,1,0.01);
  maxDelLength = 1024;
  dispersionFilter = _ <: _,_' :> *(1/2);
  delLength = ma.SR/freq;
};
pluck = hgroup("[1]Pluck",gate : ba.impulsify*gain)
with{
  gain = hslider("gain[style:knob]",1,0,1,0.01);
  gate = button("gate");
};
process = vgroup("Karplus Strong",pluck : string);
```

## Distortion

```
import("stdfaust.lib");
distortion = hgroup("Distortion", +(offset) : *(pregain) : clip : cubic : fi.dcblocker)
with{
  drive = hslider("[0]drive[style:knob]",0,0,1,0.01) : si.smoo;
  offset = hslider("[1]offset[style:knob]",0,-1,1,0.01) : si.smoo;
  pregain = pow(10,2*drive); 
  clip = min(1) : max(-1); 
  cubic(x) = x - pow(x,3)/3;
};
process = distortion;
```

## Sampling/Granular

```
import("stdfaust.lib");
repeater(detune) = rwtable(tablesize,0.0,recIndex,_,readIndex)
with{
  record = button("[2]Record") : int;
  readSpeed = hslider("[0]Read Speed",1,0.001,10,0.01);
  tablesize = 48000;
  recIndex = +(1)~*(record) : -(1) : min(tablesize-1);
  readIndex = readSpeed*(detune+1)/float(ma.SR) : (+ : ma.decimal) ~ _ : *(float(tablesize)) : int;
};
polyRepeater = vgroup("Repeater",_ <: par(i,nVoices,repeater(detune*i)) :> *(gain),*(gain))
with{
  nVoices = 10;
  detune = hslider("[1]Detune",0.01,0,1,0.01);
  gain = hslider("[3]gain",1,0,1,0.01);
};
process = polyRepeater : dm.zita_light;
```