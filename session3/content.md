# Session 3: Sound Synthesis and Processing I

Welcome to this new session on signal processing in Faust! Here, we're going to
implement a series of sound synthesizers and audio effects ready to be turned
into audio plug-ins, smartphone apps, and more (we'll give you more details on
how to do this type of things in session 5). In most cases, we'll implement
things from scratch. The goal here is not to teach you sound processing
or synthesis, but really to show you how existing techniques can be implemented
in Faust. So even though we might refresh your memory in some cases, we'll 
assume that you already have some background in DSP in general. 

We'll also spend a fair amount of time designing polished interfaces. We'll start 
with simple sound synthesis techniques such as waveshape, amplitude modulation,
frequency modulation, and subtractive synthesis. Other more advanced techniques
will be covered in session 4.

As for the previous sessions, all the code we're going to write here is
optimized to work in the Faust online editor (<https://faust.grame.fr/editor>)
so we'll use it as our main development platform.

## Lesson 1: Waveshape Synthesis

In this lesson, we use waveshape synthesis to implement a polyphonic MIDI 
synthesizer where the user can choose between a series of waveform like
sine, triangle, square, and sawtooth to generate sound. 

Waveshape synthesis (which might also be called wavetable synthesis under
certain conditions) is probably the easiest way to generate different kinds
of sounds on a computer. It consists of generating a sound by periodically 
repeating a single-cycle waveform. (TODO: link to session 2) The speed at 
which the waveform is repeated determines its period and hence its frequency. 

While any waveform can be used, standard waveforms inherited from analog 
synthesis are commonly used in the digital world. Most of you probably already 
know them but, let's quickly refresh your memory. 

[show slide 1]

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

[show screen capture]

```
os.osc() // sine wave
os.square() // square wave
os.triangle() // triangle wave
os.sawtooth() // sawtooth wave
```

All these oscillators are band-limited which means that they're aliasing-free,
as long as they are used within a certain range. While we really want to 
prevent aliasing when generating this type of sound, the main drawback is that 
these oscillators will probably not work properly if they are used under a 
certain frequency. For instance, except for `os.osc` which is naturally band
limited, `os.square`, `os.sawtooth`, `os.triangle` could not be used as Low
Frequency Oscillators (LFO). We'll get back to this later in this session 
when we use an LFO to modulate the cutoff frequency of the filter of a 
subtractive synthesizer. Note that a list of the most standards oscillators
on `oscillators.lib` is available in the libraries documentation.

[display URL: <http://faust.grame.fr/library.html#oscillatorssound-generators>]

First, let's create a `waveGenerator` circuit where our oscillators are placed
in parallel and selected using the `selectn` circuit from `basics.lib`. Note
that `selectn` is a generalized version of the `select2` primitive studied in
session 2 (TODO: make sure it was actually studied). 

[show screen capture]

```
import("stdfaust.lib");
waveGenerator = os.osc(freq),os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave)
with{
  wave = nentry("Waveform",0,0,3,1);
  freq = hslider("freq",440,50,2000,0.01);
};
process = waveGenerator;
``` 

We integrate user interface elements to our circuit to select the frequency of 
the oscillators with a slider and the waveform with a numerical entry. Note 
that we're using the standard MIDI parameter name `freq` for the frequency 
here. That way, when we turn our synthesizer into a polyphonic MIDI instrument,
its frequency will be automatically controlled by the pitch of the desired note.

[show screen capture]

Let's run this program and see if it works!

In order for our wave generator to be used as a MIDI polyphonic synthesizer,
we must add an envelope generator to it to trigger sounds when noteon 
messages are received. As you probably already know, there exists a wide range
of envelope generators and the most famous and broadly used one is the ADSR. 

[show slide 2]

Just as a quick refresher, ADSR envelope generators have 4 phases the attack, 
the decay, the sustain, and the release. That's why they're called ADSR! 

The envelope library of Faust called `envelopes.lib` contains a circuit 
implementing an ADSR envelope generator: `en.adsr`. It will output a signal
whose range is 0 to 1 where 0 corresponds to the beginning of the attack and
the end of the release and where 1 is reached at the end of the attack, right
before the decay. This means that the output of `en.adsr` will have to be 
scaled by any potential gain parameter when implementing our MIDI synthesizer. 

[show screen capture: library doc]

As we can see it in the library documentation, this circuit has 5 
inputs: the duration of the attack in seconds, the duration of the decay in 
seconds, the percentage of the gain of the sustain in function of the maximum
gain reached after the attack, the duration of the release in seconds, and
finally a trigger signal (a `button` user interface element can be used for 
that).

As we did for our `waveGenerator` circuit, let's create an `envelope` circuit
hosting user interface elements to control the various parameters of `en.adsr`.

[show screen capture (highlight `envelope`)]

```
import("stdfaust.lib");
envelope = en.adsr(attack,decay,sustain,release,gate)*gain
with{
  attack = hslider("Attack",50,1,1000,1)*0.001;
  decay = hslider("Decay",50,1,1000,1)*0.001;
  sustain = hslider("Sustain",80,1,100,1);
  release = hslider("Release",50,1,1000,1)*0.001;
  gain = hslider("gain",1,0,1,0.01);
  gate = button("gate");
};
waveGenerator = os.osc(freq),os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave)
with{
  wave = nentry("Waveform",0,0,3,1);
  freq = hslider("freq",440,50,2000,0.01);
};
process = waveGenerator;
```

We're using milliseconds as our time unit as it is more practical than seconds
in this scenario. Note that we used the standard MIDI user interface elements
name here as we did for the `freq` parameter for our `waveGenerator` circuit. 
The signal generated by our `gain` slider is multiplied to the output of the 
envelope generator.  

Let's put this together in the `process` line by multiplying our `waveGenerator`
and `envelope` circuit together:

[show screen capture]

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
or physical MIDI keyboard connected to your computer! 

[do it!]

[show screen capture: code]

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

To finish this lesson, we improved the user interface of our synthesizer by 
organizing its various elements and by changing their appearance. We created a 
`Synth` vertical group encapsulating the entire interface. We also used knobs 
for our envelope generator parameters by declaring the `[style:knob]` 
metadata in the name of the user interface elements (TODO: might want a link to 
  the doc here). 

Placing knobs horizontally helps save space in the interface so we created a 
`Envelope` horizontal group encapsulating the various elements of the envelope 
generator. We also numbered the user interface elements within this group to 
make sure they appear in the right order in the interface. We did the same for 
our wave generator.

Run the code and try to control with a MIDI keyboard as we did in previous
sessions.

[do it!]

[show screen capture: code]

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

You probably noticed that if multiple keys are pressed at the same time, the
generated sound is clicking. That's because the voices instantiated when
pressing the keys all add up without being scaled. To fix the problem, the
output of the envelope generator can be multiplied by a static number. Here
we choose 0.3.

To conclude this long lesson, we want to highlight the fact that none of the
user interface elements used here are smoothed which means that they might 
generate clicks when they are moved. As shown in session 2, this problem can
always be solved by using `si.smoo`. 

## Lesson 2: Amplitude Modulation Synthesis

In this lesson, we're going to implement a simple polyphonic MIDI synthesizer
using amplitude modulation and reusing some of the elements studied in
lesson 1 such as the envelope generator.

Amplitude modulation consists of modulating the amplitude of a signal called 
the carrier with the signal of an oscillator called the modulator. Typically,
the modulator is implemented with a sine wave oscillator but other types of
oscillators can be used. 

Amplitude modulation can be used as an audio effect when processing sounds from
the "real-world" but also as a sounds synthesis techniques when the carrier is
also generated by an oscillator.

In this lesson, we'll study this special case of amplitude modulation where
both the carrier and the modulator are implemented using sine wave oscillators.

More theory around amplitude modulation is available in the corresponding
section of Julius Smith's online book.

[show URL: <https://ccrma.stanford.edu/~jos/rbeats/Sinusoidal_Amplitude_Modulation_AM.html>]

[show screen capture: code]

```
import("stdfaust.lib");
am = carrier*modulator
with{
  carrier = os.osc(carFreq);
  modulator = os.osc(modFreq);
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  carFreq = hslider("Carrier Frequency",440,50,2000,0.01);
};
process = am;
```

Here, we're multiplying a sine wave oscillator (the carrier) by another one 
(the modulator). Our `am` circuit hosts user interface elements to control the 
frequency of the 2 oscillators.

Even though calling `am` in the process line will work and generate sound, it
doesn't do exactly what we want. 

[show slide 3]

Indeed, the range of the modulator is currently -1 to 1, which means that the 
gain of the carrier goes from 0 to 1, then 1 to 0, then 0 to -1, and finally 
-1 to 0 at every period. In other words, the current modulation frequency is 
doubled and a phase inversion happens twice per period. Instead, we want the 
modulator to go from 0 to 1 and then back to at every period.

This can be easily fixed by scaling the output of the modulator to make sure
that its range is between 0 and 1.

[show screen capture: code]

```
import("stdfaust.lib");
am = carrier*modulator
with{
  carrier = os.osc(carFreq);
  modulator = os.osc(modFreq)*0.5 + 0.5;
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  carFreq = hslider("Carrier Frequency",440,50,2000,0.01);
};
process = am;
``` 

We now want to be able to control the "depth" of the modulation which 
corresponds to the amount of modulation applied to the sound. Scaling the gain
of our modulator with a depth parameter will not be enough as if depth is 0,
no sound will be generated since the gain of `modulator` which is currently
multiplied to `carrier` will be 0 as well. 

[show screen capture: code]

```
import("stdfaust.lib");
am = carrier*modulator
with{
  carrier = os.osc(carFreq);
  modulator = ((1-modDepth) + (os.osc(modFreq)*0.5+0.5)*modDepth);
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  carFreq = hslider("Carrier Frequency",440,50,2000,0.01);
  modDepth = hslider("Modulator Depth",0.5,0,1,0.01);
};
process = am;
```

So, we need to compensate for the value of depth by adding 1 to the modulator
and subtract `modDepth` from it.

Let's see how this sounds!

[run the code]

[show screen capture: code]

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

We can now reuse the `envelope` circuit from lesson 2 to turn `am` into a
polyphonic synthesizer. Also, in order for the frequency of the synth to be
controlled with MIDI, we must rename our `Carrier Frequency` parameter to
`freq`. We also did some cleaning to the code to make the interface look a bit
nicer.

Run it and have fun playing!

[run the code]

Note that amplitude modulation works with any type of waveform and that 
triangle, sawtooth, or square waves from lesson 1 could be used here instead of 
sine waves and will likely produce richer sounds.

## Lesson 3: Frequency Modulation Synthesis

In the previous lesson, we modulated the amplitude of an oscillator using
the signal of another one. In this lesson, we're going to modulate the 
frequency of an oscillator with another oscillator. As most of you probably
already know, this sound synthesis method is called frequency modulation 
synthesis or FM. It allows for the synthesis of sounds with a very rich 
complex spectrum. Here, we're going to use it to make a polyphonic MIDI 
synthesizer.

[show screen capture: code]

```
import("stdfaust.lib");
fm = os.osc(carFreq + os.osc(modFreq)*index)
with{
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  index = hslider("Modulation Index",100,0,1000,0.01);
  carFreq = hslider("freq",440,50,2000,0.01);
};
process = fm;
```

In this `fm` circuit, the frequency of a sine wave oscillator (the carrier) is 
modulated by another sine oscillator (the modulator).
The `Modulation Index` slider controls the amount of modulation applied to the
frequency of the carrier. Its range is 0 to 1000 here but in practice, it can
be unlimited. Note that we don't need to scale the range of the modulator as 
we did in lesson 2 for amplitude modulation as we want the frequency of the 
carrier to oscillate around a certain value, which is defined here be the 
`Modulator Frequency` slider. Note that we named the slider controlling the 
carrier frequency `freq` since we want it to be controlled by MIDI events, as 
we did in previous lessons.

Let's try to run this code and see what happens!

[run the code]

We can reuse the `envelope` circuit from lesson 1 in this code to turn it
into a polyphonic MIDI synthesizer. 

[show screen capture: code]

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

You probably noticed that we made some cosmetic changes to the interface to
make it look nicer as we did for previous examples.

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

## Lesson 4: Subtractive Synthesis

In this lesson, we're going to use subtractive synthesis to implement a
polyphonic MIDI synthesizer.

Subtractive synthesis consists of sculpting sound containing a dense harmonic
content such as noise, square waves, sawtooth waves, for example, using one
or several filters.

[show screen capture: code]

```
import("stdfaust.lib");
waveGenerator = hgroup("[0]Wave Generator",no.noise,os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave))
with{
  wave = nentry("[0]Waveform",3,0,3,1);
  freq = hslider("[1]freq",440,50,2000,0.01);
};
process = waveGenerator;
```

First, we're going to reuse the `waveGenerator` circuit implemented 
in lesson 1 as the source for our subtractive synthesizer. In practice, we
can even remove the sine wave oscillator from it since it doesn't make sense
to process a pure tone through a filter in this case, and we can replace it
with a white noise generator. So now, when `wave` is equal to zero, white noise
will be generated.

Let's now create a `subtractive` circuit taking `waveGenerator` and feeding it
to a resonant lowpass filter. This kind of filter is implemented in Faust in 
the `fi.resonlp()` circuit defined in the `filters.lib` filters library. 

[show screen capture: library doc]

As you can see it in the libraries documentation, this circuit has four inputs:
the cutoff frequency, the Q, the gain, and the signal to be processed. 

[show screen capture: code]

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
  resFreq = ctFreq + os.osc(lfoFreq)*lfoDepth : max(30);
};
process = subtractive;
```

Here, in order to create a dynamic spectrum, we're going to modulate the cutoff
frequency of this filter using a low frequency sine wave oscillator. Since we
never want the cutoff frequency to be smaller or equal to zero, and even below
the human hearing range, we need put a safeguard here using `max`.

Let's now try to run this code to see how it sounds. Spend some time with the
various parameters of the synth to see what they do.

[show screen capture: code]

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

Adding the `envelope` circuit form previous lessons we can implement a
polyphonic synthesizer simply by multiplying the output of `subtractive` by
`envelope`.

Note that any kind of filter can be used here: highpass, bandpass and that they
can be daisy chained to create complex sounds and behaviors. Also, none of the
user interface elements here are smoothed, we'll leave that up to you.

Run this code and have fun playing!
