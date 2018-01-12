import("stdfaust.lib");
fm = os.osc(carFreq + os.osc(modFreq)*index)
with{
  modFreq = hslider("Modulator Frequency",20,0.1,2000,0.01);
  index = hslider("Modulation Index",100,0,1000,0.01);
  carFreq = hslider("freqo",440,50,2000,0.01);
};
process = fm;