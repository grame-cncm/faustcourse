# Session 3 - Assignment

## Exercise 1: Fun With Subtractive Synthesis

### Trying Other Types of Filter

Try using different filters with the subtractive synthesizer implemented in
Lesson 4. For example, have a look at: 
* other resonator filters 
(<http://faust.grame.fr/library.html#simple-resonator-filters>) such as
`fi.resonbp`, `fi.resonhp`
* butterworth filters (<http://faust.grame.fr/library.html#butterworth-lowpasshighpass-filters>)
such as `fi.lowpass`, `fi.highpass`
* peak equalizer filters such as `fi.peak_eq` (<http://faust.grame.fr/library.html#fi.peak_eq>) 

Observe their different effects on the sound and try various mappings with the
LFO. Also, feel free to add more LFOs to control more parameters (e.g., the
`q`).

Submit at least one Faust file implementing a MIDI-controllable subtractive
synthesizer using at least one of these filters. 

### Using Multiple Filters

Peak equalizers implemented through `fi.peak_eq` are a very powerful kind of
filter. Indeed, when their level is 0dB, they don't have any impact of the 
processed sound. This property allows them to be daisy-chained (placed in 
series). Try to put at least 2 of them in series and automate the control of
some of their parameters using LFOs. 

As a bonus point, try to use the `seq` iteration operator and pattern matching
to automatically duplicate `fi.peak_eq`. The following "meta Faust code" should
help you get started with this:

```
filters = seq(i,2,someFilter(i))
with{
  someFilter(i) = filter(a,b,c(i))
  with{
    freq = hslider("LFOFreq%i",...);
    a = LFO(freq)*i;
    b = LFO(freq)*i*2;
    c(0) = 1;
    c(1) = 2;
  };
};
``` 

Try to come up with interesting mappings and high level parameters to control.

Submit at least one Faust file implementing a MIDI-controllable subtractive
synthesizer using this system. 

## Exercise 2: Towards the DX7

The Yamaha DX7 is a "legendary" synthesizer that "democratized" the use of
digital sound synthesis in the 80's (<https://en.wikipedia.org/wiki/Yamaha_DX7>).
The DX7 was using a set of 6 sine wave oscillators that could be patched in
various ways to synthesize a broad range of sounds (see `sex7Patches.png`). 
Additionally, each parameter of each oscillator (e.g., frequency,
index of modulation, etc.) could be controlled using an envelope generator. 

The goal of this exercise is to implement a simple DX7 emulator. While it wont 
have all the features of the original instrument, it should still be
playable and musical. 

As a first step, you should implement a generic DX7 oscillator module. The
following "meta Faust code" should give you and idea of how such a module
could look like:

```
dxOsc(freq,index,a,d,s,r,mod) = os.osc(freq+mod*index)*envelope
with{
  envelope = en.adsr(a,d,s,r);
};
``` 

`freq` is the center frequency of the oscillator, and `mod` the potential
modulation signal. If the oscillator module is not to be modulated, `mod` can
just be set to 1.

An example "patch" combining 2 of these modules could look like:

```
simplePatch = dxOsc(freq0,index0,a0,d0,s0,r0,1) : dxOsc(freq0,index0,a0,d0,s0,r0);
```

Try to make a synthesizer with one patch combining at least 3 
oscillators. Feel free to copy some of the DX7 patches (see `dx7Patches.png`) 
or to create your own. Your synthesizer should be controllable via MIDI. The 
user interface is up to you: feel free to decide which parameters you want 
to put in it. You can submit multiple files implementing different patches but 
this is optional.
