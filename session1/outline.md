# Session 1 - Outline

## Background on Faust

* **What is a Faust program?** It describes a circuit to compute audio signals. 
Thus Faust can be used to write audio effects or sound synthesizers.
* TODO: Yann looks for pre-written text on Faust

## TODO: online editor

## Process Line

* `process` is the main entry point to the description of the audio circuit. 
If you're familiar with C, C++, etc., `process` corresponds to the `main` 
function of the program.
* Connections between the circuit in `process` and the audio inputs and outputs
of the machine are established automatically. Thus, a circuit with one input
and 2 outputs will be automatically connected to the first 2 physical
outputs and to the first physical input of the computer, which could be a 
microphone and 2 speakers.
* Slide 1

## First Example

```
import("stdfaust.lib");
process = button("gate") : pm.djembe(60,0.5,0.5,1);
``` 

* Display the code above
* A Faust program is a series of statements that are all terminated by a `;``
* In the current example, there are 2 statement
* The first one imports all the standard libraries. A library is a collection
of predefined circuits written in Faust. These collections are organized in a
hierarchy of environments that can be accessed using prefixes. For example, in 
the current code `pm.` corresponds to the physical modeling library. 
* The second one is our process line implementing a simple djembe physical model
triggered by a button. [Button](#button) is a user interface primitive. A 
primitive is a predefined element of the language. Button is a circuit that 
will appear as an element in the graphical user interface. It produces 
an output signal which is zero when not pressed and which is 1 while pressed. 
* The documentation of any pre-defined element can be visualized by placing the
text cursor on it and pressing `ctrl + d` or the corresponding icon in the left
menu.   
In contrast, `pm.djembe` is a user defined circuit that is part of the standard
Faust libraries. In order to use it, `stdfaust.lib` must be imported.  
* The `djembe` circuit has 5 input signals. Their role can be 
known by looking at the online documentation. -> do it!
* Slide 2: describe the 5 inputs
* In the current code, the first four inputs are specified as "function 
arguments" and the last one is connected to the `gate` button using `:`. `:` 
is the sequential composition operator. It connects the outputs of the left 
hand side circuit to the inputs of the right hand side circuit.
* Slide 3: you can now see the corresponding diagram on the screen.
* A number is also a circuit with no input and one output.
* The signal produced by a number is a DC signal of the corresponding value.
* There is an alternative notation to this functional-oriented one (slide 4)
```
60,0.5,0.5,1,button("gate") : pm.djembe;
``` 
* Note that commas are used to place circuits in parallel. We will provide
further details about this type of circuit operations in session 2. 
* Now let's run the code by pressing the run button or `ctrl + r`. Try to press
the `gate` button and see what happens. 
* This was just an example, now Let's get back to the original code which is
more legible in this case:
```
import("stdfaust.lib");
process = button("gate") : pm.djembe(60,0.5,0.5,1);
``` 
* We're now going to add a reverb to our instrument. For that we're gonna use
the `freeverb` circuit of the standard library. It is tempting to write the 
following code:
```
process = button("gate") : pm.djembe(60,0.5,0.5,1) : dm.freeverb_demo;
```
but it will produce an error because `dm.freeverb_demo` has 2 inputs while 
`pm.djembe` has only one output. 
* Try to run the code and see what happens.
* What a user friendly error message! `Error in sequential composition (A:B)`
means that the number of outputs of `A` is the not the same as the number of
inputs of `B`.
* To fix this, we need to use the split composition operator `<:` which will
split the output of `pm.djembe` and connect it to the 2 inputs of 
`dm.freeverb_demo`.
* Here's the correct code:
```
import("stdfaust.lib");
process = button("gate") : pm.djembe(60,0.5,0.5,1) <: dm.freeverb_demo;
```
* Try to run your Faust code again and see what happens.
* You probably noticed that there are new elements in the user interface. This
is because these elements are part of the definition of `dm.freeverb_demo`.
* Now, let's automate the performance by automatically triggering the 
djembe using the `ba.pulsen` circuit. Once again, you can check the 
documentation of `ba.pulsen` by placing the text cursor on it and pressing 
`ctrl + d`. This circuit has 2 inputs, the first one is size of the impulse as
a number of samples (in our case just one sample), the second one is the period
of impulses in samples. Thus, if the period is 44100 and your sampling rate is
also 44100 Hz, then one pulse will be generated every second:
```
import("stdfaust.lib");
process = button("gate")*ba.pulsen(1,4410*2) : pm.djembe(60,0.5,0.5,1) <: dm.freeverb_demo;
```
* As an exercise, try to add another impulse generator running at a different
period to create some polyrythm effect. You can now pause the video and try to
do this.
* One solution to the previous exercise could be:
```
import("stdfaust.lib");
process = button("gate")*(ba.pulsen(1,4410*2) + ba.pulsen(1,4410*1.3)) : pm.djembe(60,0.5,0.5,1) <: dm.freeverb_demo;
``` 
* Let's now change the name of the current Faust program by calling it 
`djembe.dsp` in the drop zone.
* This can be exported as a ready-to-use Android application by selecting the
Android platform and the Android target in the export tool of the online 
editor. -> do it!
* Once the online compiler is done, it will display a QR code pointing at the
application package. This might take a while, be patient, have a cup of Lipton
tea or a shot whiskey.  
* If you're an unfortunate iOS device owner, the online compiler will only be
able to generate an XCode project that you'll have to compile directly on your
computer. Note that the same can be done for Android and will significantly 
reduce the duration of the online compilation process.

## Polyphonic MIDI Synthesizer

```
import("stdfaust.lib");
gain = hslider("gain",0.5,0,1,0.01);
process = gain*os.sawtooth(440);
```

```
import("stdfaust.lib");
gain = hslider("gain",0.5,0,1,0.01);
process = gain,os.sawtooth(440) : *;
```

```
import("stdfaust.lib");
gain = an.amp_follower_ar(0.02,0.02);
process = gain,os.sawtooth(440) : *;
```
 
```
import("stdfaust.lib");

freq = hslider("freq",440,50,1000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate");

organ = timbre(freq)*envelope
with{
  timbre(f) = (os.osc(f)*0.75 + os.osc(f*2)*0.5 + os.osc(f*3)*0.25)/3;
  envelope = gate : en.adsr(0.01,0.01,90,0.1)*gain;
};

process = organ;
```



