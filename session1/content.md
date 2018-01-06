# Session 1 - Outline

## Introduction

* Hi everyone! Welcome to this course on real-time audio signal processing in 
Faust! I'm Romain Michon and I'm Yann Orlarey, and we're going to teach you
this course together. There will be also lessons by Julius Smith and Chris 
Chafe.
* Romain's bio
* Yann's bio 

* TODO
* Faust is a functional programming language for sound synthesis and audio 
processing with a strong focus on the design of synthesizers, musical 
instruments, audio effects, etc. 
* Faust is used on stage for concerts and artistic productions, in education 
and research, in open source projects as well as in commercial applications.
* You don't have to be a computer scientist or a professional developer to
program with Faust.
* In this course we will teach you how to use Faust to design your own
electronic musical instruments and audio effects. After this course, you will
be able to write your own VST and Audio Unit plug-ins, make Android and iOS
applications, externals for various computer music languages such as Max, PD,
SuperCollider, CSOUND, ChucK and more.
* In this regard, Faust can be seen as an alternative to C++ but is much 
simpler and intuitive to learn.
* While Faust comes as a command line compiler in its most primitive form, it
can be programmed through an online tool that doesn't require any installation.
Thus, Faust code can be written and executed directly in a web browser!
* In the next section, we'll show you how to use the online editor that will 
be used as the main development platform throughout this course.
* The Faust online editor makes use of cutting edge web technologies such as 
webassambly and of course the webaudio API. Thus, you must use a very recent 
web browser supporting webassembly. That said, some examples provided in this 
course will need MIDI support. Currently only Google Chrome supports the Web 
MIDI API. Thus we recommend you to use this browser for this course.
* The Faust web editor can be found at the following URL: 
<https://faust.grame.fr/editor> 
* Alternatively, you can also find it on GitHub: 
<https://grame-cncm.github.io/fausteditorweb/>.
* When you connect to the editor, you'll find a default Faust program which is 
a circuit mixing 2 input signals.
* This program is made out of 2 statements: the first one imports the standard
Faust libraries and the second one in the mandatory definition of the `process`
keyword which is the main entry point to the program.
* Let's replace the definition of process with our own:

```
import("stdfaust.lib");
process = button("gate") : pm.djembe(60,0.5,0.5,1);
```

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
* A Faust program is a series of statements that are all terminated by a `;`
* In the current example, there are 2 statements
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
In contrast, `pm.djembe` is a user-defined circuit that is part of the standard
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
`ctrl + d`. This circuit has 2 inputs, the first one is the size of the impulse as
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

## Controlling an Oscillator With Breath 

* Let's start a new example now. The final goal is to make a simple sound 
generator whose envelope will be controlled by blowing onto the built-in
microphone of the computer.
* First, let's write a simple sawtooth oscillator with a constant gain and 
frequency (remember that you can check the documentation of a Faust function
by placing the text cursor on it and pressing `ctrl + d`).
* For now, we'll set the gain to 0.5 to make sure that the generated sound is
not too loud. 
* We could have used 0.5 directly in the process definition, but instead we 
introduce a new definition for this that we name `gain` and that we will
complexify later. 

```
import("stdfaust.lib");
gain = 0.5;
process = gain*os.sawtooth(440);
```

* This is a "math oriented" way of writing a program which is called "infix" 
notation.
* An equivalent and more "circuit oriented" notation consists of placing 
circuits in parallel and connect them to a multiplier as follows:

```
import("stdfaust.lib");
gain = 0.5;
process = gain,os.sawtooth(440) : *;
```

* Let's now assign a new type of user interface element to `gain`: `hslider` 
which is a horizontal slider (link to doc).
* `hslider` has 5 parameters: the first one is the name of the slider in the
interface, the second one is the default value produced by the slider on 
startup, the third one is its minimum value, the fourth one its maximum value,
and finally the fifth one its precision.

```
import("stdfaust.lib");
gain = hslider("gain",0.5,0,1,0.01);
process = gain,os.sawtooth(440) : *;
```

* Don't forget to try to run the program to see what it does.
* We now want to control the gain of the oscillator by blowing onto the 
microphone. In order to do this, we will replace the slider by an amplitude
tracker: `an.amp_follower_ar` (also called envelope follower). This circuit 
takes three inputs: the duration of the attack of the envelope in seconds,
the duration of the release in seconds, and the signal to be analyzed:

```
import("stdfaust.lib");
gain = an.amp_follower_ar(0.02,0.02);
process = gain,os.sawtooth(440) : *;
```
 
* Show block diagram.
* Try to run the program and blow onto the built-in microphone of your laptop
to see if this works. 
* Take good notes of this as it might be needed in this session's assignment. 
 
## Polyphonic MIDI Organ

* In this section, we will create a simple MIDI controllable polyphonic organ 
synthesizer. 
* The first step consists of implementing an additive synthesizer which will
determine the timbre of the organ. 
* A simple additive synthesizer can be implemented by adding three (it could 
also be more) sine wave oscillators together. Timbre will be determined by the 
relationship between the parameters of the various harmonics implemented by
each oscillator.

```
import("stdfaust.lib");
process = os.osc(440)*0.5 + os.osc(440*2)*0.25 + os.osc(440*3)*0.125;
```
 
* We now want to generalize this expression for any frequency. To do this, we
need to introduce the concept of parameter, which is very important. 
* The previous program can be rewritten as such:

```
import("stdfaust.lib");
timbre(f) = os.osc(f)*0.5 + os.osc(f*2)*0.25 + os.osc(f*3)*0.125;
process = timbre(440);
```

* We now want to control the gain and frequency of `timbre`. For that, we must 
create new user interface elements.

```
import("stdfaust.lib");
freq = hslider("freq",440,50,1000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
timbre(f) = os.osc(f)*0.5 + os.osc(f*2)*0.25 + os.osc(f*3)*0.125;
process = gain*timbre(freq);
```

* We're almost ready to turn the previous code into a polyphonic MIDI 
synthesizer.
* We remind you that pressing a key on a MIDI keyboard will trigger a "key on"
message containing 2 information: the key number and the key velocity.
* Inversely, releasing the key will trigger a "key off" message containing the
same parameters.
* In order to map MIDI messages to the audio parameters of the Faust program
we must respect some naming conventions for these parameters. More precisely,
three parameters must be declared: `freq` which will be controlled by the key
number, `gain` which will be controlled by the velocity, and `gate` which will
output 1 while the key is pressed and 0 otherwise:

```
import("stdfaust.lib");
freq = hslider("freq",440,50,1000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate");
timbre(f) = os.osc(f)*0.5 + os.osc(f*2)*0.25 + os.osc(f*3)*0.125;
process = gain*gate*timbre(freq);
```

* We can now test the program in 2 different modes. First, without polyphony 
just by running as such. -> do it
* The next step will only work in Google Chrome as MIDI support is only 
available in this web browser (e.g., if you're using Firefox, it will not 
work).  
* If you have a MIDI keyboard, you can now plug it to your computer. Otherwise, 
you can use a virtual MIDI keyboard such as TODO. 
* Now, we can turn the polyphony on (show it) and re-run the Faust program.
* Since multiple notes can be played together, we must scale down the gain
of our synthesizer. For now, let's just multiply the `process` line by 0.5:
 
```
process = gain*gate*timbre(freq)*0.5;
``` 

* You probably noticed that there are clicks when a new note is started. This
is due to the lack of envelope. We can easily connect the output of the `gate`
button to an ADSR envelope generator. ADSR is a circuit with 5 inputs: 
    * duration of the attack in seconds
    * duration of the decay in seconds
    * sustain level as a percentage of the maximum gain
    * duration of the release in seconds
    * the trigger signal (the attack begins when this rises to 1 and the
      release is triggered when this goes down to 0) 

```
import("stdfaust.lib");
freq = hslider("freq",440,50,1000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate") : en.adsr(0.01,0.01,90,0.1);
timbre(f) = os.osc(f)*0.5 + os.osc(f*2)*0.25 + os.osc(f*3)*0.125;
process = gain*gate*timbre(freq)*0.5;
```

* To finish this session, we want to add a sweet reverb to the our polyphonic
synthesizer. While we could do this by connecting the output of the current
synthesizer to a reverb circuit directly in the `process` line, this would be
highly inefficient as the reverb would be duplicated for each voice. 
Fortunately a global audio effect can be applied to all the polyphonic voices
at once by defining an `effect` element anywhere in the code.
* A good reverb circuit with a simplified user interface is `dm.zita_light`.
* The number of outputs of a single voice of the polyphonic synthesizer must 
be the same as the number of inputs of the effect. 
* Since `dm.zita_light` is a stereo reverb, it takes 2 inputs. Thus the output
of process must be split into 2 signals. This can be easily done in Faust by
using the split operator (`<:`) followed by a stereo circuit conceptually 
equivalent to a stereo cable. Split the baguette!
We'll provide more details about this type of construction in session 2. 

```
import("stdfaust.lib");
freq = hslider("freq",440,50,1000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate") : en.adsr(0.01,0.01,90,0.1);
timbre(f) = os.osc(f)*0.5 + os.osc(f*2)*0.25 + os.osc(f*3)*0.125;
process = gain*gate*timbre(freq)*0.5 <: _,_;
effect = dm.zita_light;
```

* As previously, this Faust program could be exported as a mobile application.
If a MIDI keyboard were to be plugged to the mobile device running this app,
it would be able to control it just like in the web editor.



