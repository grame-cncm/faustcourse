import("stdfaust.lib");
waveGenerator = os.osc(freq),os.triangle(freq),os.square(freq),os.sawtooth(freq) : ba.selectn(4,wave)
with{
  wave = nentry("Waveform",0,0,3,1);
  freq = hslider("freq",440,50,2000,0.01);
};
process = waveGenerator;