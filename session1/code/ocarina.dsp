declare interface "SmartKeyboard{
	'Number of Keyboards':'2',
	'Max Keyboard Polyphony':'12',
	'Keyboard 0 - Number of Keys':'4',
  	'Keyboard 1 - Number of Keys':'4',
	'Keyboard 0 - Lowest Key':'60',
	'Keyboard 1 - Lowest Key':'67',
	'Keyboard 0 - Scale':'2',
	'Keyboard 1 - Scale':'2',
	'Rounding Mode':'0'
}";

import("stdfaust.lib");

freq = hslider("freq",440,50,3000,0.01);
gain = hslider("gain",1,0,1,0.01);
gate = button("gate");

//envelope = gain*gate : si.smoo;
envelope = *(gate) : an.amp_follower_ar(0.01,0.01);
synth = os.triangle(freq)*envelope;

process = synth;
			