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