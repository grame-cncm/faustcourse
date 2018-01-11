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

## Lesson 1: Waveshape Synthesis

TODO

Waveshape synthesis (which might also be called wavetable synthesis under
certain conditions) is probably the easiest kind of sound synthesis. It 
consists of generating a sound by periodically repeating a single-cycle 
waveform. (TODO: link to session 2) The speed at which the waveform will be 
repeated will determine its period and hence its frequency. 

While any waveform can be used, standard waveforms inherited from analog 
synthesis are commonly used in the digital world. Most of you probably already 
know them but let's quickly refresh your mind. 

[slide 1: TODO]

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

All these oscillators are band-limited which means that they're aliasing free,
as long as they are used within a certain range. [TODO: may be add a link
explaining what aliasing is]. While we really want to prevent aliasing when
generating this type of sound, the main drawback is that these oscillators
will probably not work properly if they are used under a certain frequency.
For instance, except for `os.osc` which is naturally band
limited, `os.square`, `os.sawtooth`, `os.triangle` could not be used as Low
Frequency Oscillators (LFO).   

* Show `selectn`

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

* Don't forget to play the synth without adjusting the gain of the modulator
to highlight the phase inversion
* Show that this works with different waveforms: may be it's a good time to
introduce standard functions...
* Show the effect of FM on the spectrum of the sound: side bands, may be a bit
of maths.
* It'd be nice to plot the spectrum
* LFO will be studied in session 2

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

## Frequency Modulation

* Explain that different waveforms can be used.
* May be some maths to explain sidebands
* It'd be nice to plot the spectrum 

* Simple case:

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

* Case with harmonicity ratio control

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

* TODO: To finish

```
import("stdfaust.lib");
waveGenerator = hgroup("[0]Wave Generator",os.osc(freq),os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave))
with{
  wave = nentry("[0]Waveform",3,0,3,1);
  freq = hslider("[1]freq",440,50,2000,0.01);
};
subtractive = waveGenerator : hgroup("[1]Filter",filter)
with{
  ctFreq = hslider("[0]Cutoff Frequency[style:knob]",2000,50,10000,0.1);
  q = hslider("[1]Q[style:knob]",5,1,30,0.1);
  lfoFreq = hslider("[2]LFO Frequency[style:knob]",10,0.1,20,0.01);
  lfoDepth = hslider("[3]LFO Depth[style:knob]",500,1,10000,1);
  resFreq = os.osc(lfoFreq)*lfoDepth + ctFreq : max(30);
  filter = fi.resonlp(resFreq,q,1);
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