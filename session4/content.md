# Session 4: Advanced Sound Synthesis in Faust

## Amplitude Modulation

* Don't forget to play the synth without adjusting the gain of the modulator
to highlight the phase inversion
* Show that this works with different waveforms: may be it's a good time to
introduce standard functions...
* Show the effect of FM on the spectrum of the sound: side bands, may be a bit
of maths.
* It'd be nice to plot the spectrum

```
import("stdfaust.lib");
modulatorFreq = hslider("[0]Modulator Frequency",20,0.1,2000,0.01);
modulatorDepth = hslider("[1]Modulator Depth",0.5,0,1,0.01);
carrierFreq = hslider("[2]freq",440,50,2000,0.01);
gain = hslider("[3]gain",1,0,1,0.01);
gate = button("[4]gate");
am(cFreq,mFreq,depth) = carrier*modulator
with{
  carrier = os.osc(cFreq);
  modulator = ((1-depth) + (os.osc(mFreq)*0.5+0.5)*depth);
};
envelope = gate*gain : si.smoo;
process = am(carrierFreq,modulatorFreq,modulatorDepth)*envelope;
```

## Frequency Modulation

* Explain that different waveforms can be used.
* May be some maths to explain sidebands
* It'd be nice to plot the spectrum 

* Simple case:

```
import("stdfaust.lib");
modulatorFreq = hslider("[0]Modulator Frequency",20,0.1,2000,0.01);
modulationIndex = hslider("[1]Modulation Index",100,0,1000,0.01);
carrierFreq = hslider("[2]freq",440,50,2000,0.01);
gain = hslider("[3]gain",1,0,1,0.01);
gate = button("[4]gate");
fm(cFreq,mFreq,index) = os.osc(cFreq + os.osc(mFreq)*index);
envelope = gate*gain : si.smoo;
process = fm(carrierFreq,modulatorFreq,modulationIndex*envelope)*envelope;	
```

* Case with harmonicity ratio control

```
import("stdfaust.lib");
harmonicityRatio = hslider("[0]Harmonicity Ratio",1,0,10,0.01);
modulationIndex = hslider("[1]Modulation Index",100,0,1000,0.01);
carrierFreq = hslider("[2]freq",440,50,2000,0.01);
gain = hslider("[3]gain",1,0,1,0.01);
gate = button("[4]gate");
fm(cFreq,harmRatio,index) = os.osc(cFreq + os.osc(cFreq*harmRatio)*index*harmRatio);
envelope = gate*gain : si.smoo;
process = fm(carrierFreq,harmonicityRatio,modulationIndex*envelope)*envelope;	
```

## Subtractive

* TODO: To finish

```
import("stdfaust.lib");
harmonicityRatio = hslider("[0]Harmonicity Ratio",1,0,10,0.01);
modulationIndex = hslider("[1]Modulation Index",100,0,5000,0.01);
carrierFreq = hslider("[2]freq",440,50,2000,0.01);
gain = hslider("[3]gain",1,0,1,0.01);
gate = checkbox("[4]gate");
fm(cFreq,harmRatio,index) = os.osc(cFreq + os.osc(cFreq*harmRatio)*index*harmRatio);
envelope = en.adsr(1,0.01,90,0.1,gate)*gain;
subtractive = synth : filter
with{
  synth = fm(carrierFreq,harmonicityRatio,modulationIndex*envelope);
  resFreq = os.osc(10)*2000 + 2500;
  filter = fi.resonlp(os.osc(10)*2000+2500,7*envelope+1,1);
};
process = subtractive*envelope;
```

## Sampling

```
import("stdfaust.lib");
freq = hslider("freq",1,0.001,10,0.01);
gain = hslider("gain",1,0,1,0.01);
a = hslider("a",0,0,1,0.01);
record = button("record") : int;
gate = checkbox("gate") : int;
cnt0 = +(1)~*(record) : -(1) : min(48000);
phasor(tablesize,freq) = freq/float(ma.SR) : (+ : ma.decimal) ~ _ : *(float(tablesize));
process = _ <: par(i,10,rwtable(48000, 0.0, cnt0, _, int(phasor(48000,freq*(i*a+1))))) :> *(gate*gain : si.smoo);
```