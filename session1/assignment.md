# Session 1 - Assignment

## Exercise 1: Polyphonic Synthesizer

Reuse the last example of session 1 implementing a polyphonic organ and 
replace the `timbre` definition by a sawtooth oscillator. For this, try to find 
the sawtooth circuit in the online documentation of the Faust libraries. 

Answer: 

```
import("stdfaust.lib");
freq = hslider("freq",440,50,1000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate") : en.adsr(0.01,0.01,90,0.1);
timbre(f) = os.sawtooth(f);
process = gain*gate*timbre(freq)*0.5 <: _,_;
effect = dm.zita_light;
```

## Exercise 2: Breath Controlled Polyphonic Synthesizer

Replace the envelope generator from the answer you gave in exercise 1 by a 
breath controller from the built-in microphone of your computer as we did in
session 1. Unlike in the previous example, we wont hear any sound unless we 
blow onto the microphone. The instrument should still be polyphonic and 
no sound should be generated if no key is pressed. In other words, we're trying
to make a Melodica.

## Step 3 (Bonus)

Turn the previous code into an Android or iOS app using SmartKeyboard:

```
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
```

