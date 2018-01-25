# Session 5: Deploying Faust Programs

One of the powers of Faust lies in its ability to turn Faust code into a large
number of ready-to-use objects ranging from audio plug-ins to mobile apps. 
In this last session, we're going to dig in into the lower level features of 
Faust. We'll give you an overview of the Faust ecosystem and of how things work
under the hood. We'll give you some details on how DSP algorithms implemented
in Faust can be debugged by plotting the signal they output. Finally, we'll
detail the way various Faust targets work. In particular, we'll demonstrate how 
to make smartphone based instruments or how to generate DSP engines for various 
platforms using `faust2api`.

Before we get started, we want to highlight the fact that while the online
editor is fully cross-platform, some of the tools presented in this session
might only work on Mac OSX and Linux.

## Lesson 1: Faust Architectures

As you learned throughout this course, Faust supports a wide range of targets
and allows us to export a Faust program to various plug-ins standards, 
standalones, unit generators, mobile and apps, and more. 

In this quick lesson, we give an exhaustive overview of the Faust targets and
we show you how to use them.

[show slide 1]

Here's an overview of the various targets that Faust currently supports. Some
of them are completely cross platform while others are tight to a specific
platform. For example, CoreAudio will only work on Apple devices.

The remote compilation feature of the online editor is great as it allows us to 
try the various Faust targets without installing the corresponding dependencies.
For example, if you wanted to compile a Faust program as a Max/MSP external
directly on your computer, you should have the Max/MSP SDK/libraries 
installed on your system. While this course in general focuses on the use of the
online editor, we'll briefly show you how to compile Faust objects directly on
your computer at the end of this session. 

While the dependencies related to some platforms are relatively lightweight, 
others such as Android require you to install gigabytes of elements on your system. 

There's one specific case where remote compilation is not even possible. Indeed, 
iOS apps can only be installed on a mobile device through XCode which defeats 
the purpose of remotely compiling the app. In this case, the remote compiler
will provide a ready to be compiled XCode project.

That being said, let's try to compile a Faust object for various platforms. 
Keep in mind that this all can be done through the export function of the 
online editor.

Let's write a simple Faust program calling the `dm.zita_light` circuit that we
used throughout this course.

```
declare name "myreverb";
import("stdfaust.lib");
process = dm.zita_light;
```

You probably remember that it hosts its own user interface elements so we don't
have to add anything here.

And then demo of caqt, VST, Max, and PD.

## Lesson 2: `faust2smartkeyb`: Making Smartphone Instruments

The Faust standard user interface is perfectly adapted to various cases such
as audio plug-ins, and most standalone applications. However, touch screens
on mobile devices can be exploited in a better way and sliders, knobs, and
buttons don't always cover our needs. For example, let's say you want to
turn the entire screen of the device into a continuous X/Y control surface,
you wouldn't be able to do that with standard Faust UI elements. 

The Faust distribution comes with a tool called `faust2smartkeyb`, which we
already used earlier in this course. It can
be used to generate Android and iOS apps with an interface better suited to
touchscreens and targeting skill transfer. Skill transfer consists of leveraging
performers skills to facilitate the learning of a digital musical instrument.
For example, if you're a guitar player, you might want your interface to have
a pitch mapping similar to a fretboard.

In this lesson, we show you how to use `faust2smartkeyb` to make 
mobile-device-based digital musical instruments. Things should work more or
less the same on iOS and Android, so you can use either of these 2 platforms for
this lesson. Note that this lesson is not about Android and iOS development,
therefore we'll assume that your development toolchain for these 2 platforms
is already up and running. More information about this can be found at the URL
that prompts on your screen. 

[show URL: <https://ccrma.stanford.edu/~rmichon/faustTutorials/#making-faust-based-smartphone-musical-instruments>]

First, you should check the documentation of `faust2smartkeyb` as we wont cover
all its features here.

[show URL: <https://ccrma.stanford.edu/~rmichon/smartKeyboard/>]

Also, note that various tutorials are available on the web about using
`faust2smartkeyb` in many different contexts.

[show URL: <https://ccrma.stanford.edu/~rmichon/faustTutorials/>]

In the examples folder, you should find a folder called `smartKeyboard` 
containing a wide range of examples of `faust2smartkeyb` apps. Let's take 
`trumpet.dsp` and drop it in the online editor. Then, in the export function,
we can choose the source/smartkeyboard-android target to get the source code
of our Android app.

Once the app project is generated, we can open it in Android Studio or XCode. Some
updates might have to be made here such as the version of Gradle or the target
SDK on Android or the bundle identifier on iOS. We'll let you figure that out,
it should be relatively simple.

At this point just run the app on your target device, it could be the emulator
of course. In our case, we own an Android phone, so we'll do this demo for 
Android. 

[run the app]

As you can see, we get an app with multiple keyboards in parallel controlling
a simple synth that sounds a bit like a trumpet.

Let's now have a look at the code. You can see that the synth is just a
sawtooth wave going through a lowpass filter. The `freq`, `gain`, and `gate`
parameters are declared and automatically associated to the keyboard
interface. Note that the `freq` circuit is computed in function of the `freq`
and `bend` parameters. Indeed, in order to have continuous pitch control and
to respect MIDI standards, things must be implemented this way. `bend` is also
a standard UI parameter name that will be automatically associated to the
interface.

`polySmooth` is important here as it smooths the `bend` parameter but only
after the gate signal has been sent. This prevents ugly sweeps from happening
when a new note is started and a voice is reused. 

The cuttoff frequency of the lowpass filter is computed in function of the `y`
parameter. `y` is also a standard UI name used by `faust2smartkeyb` and always
provides the normalized position (a number between 0 and 1) of a finger in a
key. Therefore, this allows for the control of the cuttoff frequency of the
lowpass with the y position of the finger in the current key. The same approach
can be used using the `x` parameter. 

At the beginning of the code, we can find the `SmartKeyboard` interface 
declaration, this is where the touchscreen interface replacing the standard 
UI elements is configured.

[Just briefly describe what's going on]

Look at the documentation of `faust2smartkeyb`

[show URL: <https://ccrma.stanford.edu/~rmichon/smartKeyboard/>]

and try to play with the different parameters to see how this works. 

As we said earlier, `faust2smartkeyb` is not limited to making apps with a
keyboard interface. So, let's now study a completely different example where
the touch screen is used as an X/Y continuous controller and where the built-in
accelerometers of the device are mapped to sound synthesis parameters. 

The `smartKeyboard` folder in the examples folder
contains a file called `toy.dsp`. Let's drag and drop it in the online editor.

Let's generate the corresponding `faust2smartkeyb` source code as we did before
and install the app on our device using Android studio.

Let's have a look at the code to try to understand what's going on here. An
impulse train is fed into a resonant lowpass filter that is used to apply a
pitch to the impulses. The filter is then connected to an echo to add more
density to the generated sound. Finally, a harmonic distortion normally used
as a guitar pedal effect helps make our instrument sound louder considering
that its sound will be played back on the built-in speaker of the mobile
device that are likely to be not very powerful.

The X/Y interface is created by configuring a single keyboard with just one
key. Since polyphony mode is set to 0, computation starts when the app is
launched (as opposed to when a key is pressed). Static mode prevents the color
of the key to change when it is touched and finally, we ask the X and Y
parameters to be numbered in functions of fingers present on the screen. For
example, the first finger to touch the screen will be associated to X0 and Y0,
the second finger X1 and Y1, etc.

Therefore, the X position of the first finger will control the rate at which
impulses are generated, and its Y position the resonant frequency of the lowpass
filter, in other words the pitch of the generated sounds. Finally, the Y 
position of the second finger controls the gain of the distortion.

The `acc` metadata is used to assign accelerometers to other parameters and
configure their mapping. For instance, the X axis of the accelerometer controls
both the duration of the delay of the echo and the Q parameter of the filter. 
The feedback of the echo is controlled by the Y axis of the accelerometer. If
you're curious to learn more about accelerometer and gyroscope mapping in Faust
we recommend you to read this short tutorial.

[show URL: <https://ccrma.stanford.edu/~rmichon/faustTutorials/#using-built-in-sensors-to-control-parameters>]

## Lesson 3: Plotting Signals

The error messages returned by the Faust compiler tell us about potential
issues in the code of a Faust program, but they don't help us debug the 
algorithm we're implementing. Indeed, a Faust program might compile without
any error but might not make any sound. 

In this short lesson, we show you how to plot the samples generated by a Faust 
program. This, combined with the ability to plot the block diagram of a Faust
code can be of great help when it comes to solve DSP-related issues.

In the online editor, you can export your Faust program as a signal plotting
command line application. Unfortunately, this functionality will only work 
on Linux and Mac OSX. When executed, the returned application will output a 
Matlab/Octave file hosting a vector or a matrix (depending if the program 
computes one or more signals), containing the first N samples output by the 
algorithm implemented in the Faust file.

[show screen capture: code]

```
process = _~+(1);
```

Let's implement a simple counter and plot it's output in the terminal. This
code uses feedback to create a loop and adds one at each sample. Let's give it
a name (`cnt.dsp`) and export it using the plot target for the platform you're 
using.

[show screen capture: do it]

This generates a command line program named after the Faust file and that can
be executed in the terminal.

[show screen capture: run]

```
./cnt
```

This outputs matlab (or octave) code that could be saved in a file by 
redirecting the output:

[show screen capture: run]

```
./cnt > cnt.m
``` 

You probably noticed that the number of samples in `faustout` is currently limited
to 16, this can be changed using the `-n` option when calling `cnt`:

[show screen capture: run]

```
./cnt -n 50
```

Ok, now let's try a more useful example where we plot the waveform of a sine
wave using octave. 

[show screen capture: code]

```
import("stdfaust.lib");
process = os.osc(440);
```

Let's follow the same steps as previously to create an `osc` command line 
application. Then let's generate the octave code from the Faust file containing 
the first 1000 samples:

```
./osc -n 1000 > osc.m
```

Octave is a free opensource software similar to Matlab. If it is installed on 
your system, you should now just be able to plot the waveform of our Faust
program by running:

[show screen capture: run]

```
octave --persist osc.m
``` 

Note that any standard octave or matlab operations can be carried out on this
signal. For example, its spectrogram could be plotted or we could just compute
its Fast Fourier Transform.

## Lesson 4: `faust2api`: Marking DSP Engines Using Faust 

In this lesson, we're going to use `faust2api` to generate a ready-to-use DSP
engine for Android. `faust2api` is not limited to Android and can do the same
thing for most of the targets supported by Faust like iOS, Jack, CoreAudio,
JUCE, Alsa, RTAudio, and more.

The goal of this lesson is not to teach you Android development so we'll assume
that your Android toolchain is up and running: this is essentially just a
demo of what can be done using `faust2api`. 

[show screen capture: do it]

Let's create a new app project in Android studio with application name 
`FaustAudio`, company domain: whatever you want, and include C++ support.

In the following step, we can keep the default settings to target Phones and
Tablets running at least on API 17.

Let's then create an empty activity using the default settings. Finally, we 
choose the default configuration for C++ support.

At this point, we should be able to run the app in the emulator or on a real 
phone. Not much will happen since this project is empty. 

Let's now write a simple Faust synthesizer program using subtractive synthesis
quite similar to the one implemented in the previous sessions.

[show screen capture: code]

```
import("stdfaust.lib");
freq = nentry("freq",200,40,2000,0.01);
gain = nentry("gain",1,0,1,0.01) : si.smoo;
gate = button("gate") : si.smoo; 
cutoff = nentry("cutoff",5000,40,8000,0.01) : si.smoo;
q = 5;
process = vgroup("synth",os.sawtooth(freq)*gain*gate : fi.resonlp(cutoff,q,1) <: _,_);
```

It is just made out of a sawtooth oscillator connected to a resonant lowpass 
filter. Note that we smooth the gate button in order to implement a simple
envelope and that we split the output of the filter into 2 signals. Indeed,
the signals at the end of the `process` line will directly connect to the
physical output of the device, so if the Android phone we're using has 2
speakers, we need the Faust program to output 2 signals. 

The frequency (`freq`), the gain (`gain`), the on/off parameter (`gate`) and 
the cut-off frequency (`cutoff`) are associated to UI elements here in order to 
control them in our Android app in JAVA. In practice, these UI elements will 
never be created but we will use their name to access the different parameters. 
The Faust compiler will basically build a parameter names tree based on what 
was declared in the Faust code. For instance, the following parameters will be 
accessible:

[show screen capture: code]

```
/synth/freq
/synth/gain
/synth/gate
/synth/cutoff
```

Let's name our code `synth.dsp` and export using the `api/android` target.

We're getting a zip file containing all the source files needed to embed our 
Faust object in the Android app as well as a markdown documentation specific to 
that object (`README.md`). We strongly recommend you to read it now. 
Additionally, we encourage you to check the `faust2api` documentation at this 
point.

[show URL: <https://ccrma.stanford.edu/~rmichon/faust2api/>]

The `java` folder in a zip file contains the JAVA portion of the API and 
the `cpp` folder, its C++ portion. The JAVA package associated with this 
API is `com.DspFaust`.

Let's now create a folder path `/app/src/main/java/com/DspFaust` in our app and 
copy and paste the content of `dsp-faust/java` in it. This can be done in 
Android Studio or directly in your file browser. Basically, as usual, the 
package of JAVA classes must follow the path where JAVA files are placed. 
Similarly, let's copy the content of `dsp-faust/cpp` in `app/src/main/cpp`.

In Android Studio, in the application tree on the left, let's open 
`External Build Files/CMakeLists.txt` and replace its content with:

```
cmake_minimum_required(VERSION 3.4.1)
add_library( dsp_faust SHARED src/main/cpp/java_interface_wrap.cpp src/main/cpp/DspFaust.cpp )
find_library( log-lib log )
target_link_libraries( dsp_faust ${log-lib} )
```

This will take care of setting up compilation paths for the C++ portion of our
Android app and specify the name of the generated module which is `dsp-faust` 
here.

Let's now open `Gradle Scripts/build.gradle (Module: app)` which sets the C++
flags for our app project and let's use the following flags:

```
cppFlags "-O3 -fexceptions -frtti -lOpenSLES"
```

We can now re-sync the project and hopefully we wont get any error.

Our Faust DSP engine is now ready to be used in the JAVA source code of the
Android app. Let's do this directly in the on `onCreate` method of the 
`MainActivity`:

[show screen capture: code]

```
package ccrma.faustaudio;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import com.DspFaust.DspFaust;

public class MainActivity extends AppCompatActivity {
    DspFaust dspFaust;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        int SR = 48000;
        int blockSize = 128;
        dspFaust = new DspFaust(SR,blockSize);
        dspFaust.start();
    }

    @Override
    public void onDestroy(){
        super.onDestroy();
        dspFaust.stop();
    }

}
``` 

So all we have to do is instantiate the `DspFaust` object and specify a sampling
rate and a block size. Calling the `start()` method will start computation
and audio buffers will be processed. Note that we're calling `stop()` in
`onDestroy` to stop computation when the app is terminated. Since this is all
happening in JAVA, no need to deinstantiate our `dspFaust` object thanks to
garbage collection.

If we run the app at this point, it will work but no sound will be generated.
That's because the default value of the `gate` parameter is 0 since it is
controlled by a button. So in order to hear something, we must set the value
of this parameter to 1. Let's add:

```
dspFaust.setParamValue("/synth/gate", 1);
```

right after the `start()` call and that should do the trick. Note that we're 
using the `/synth/gate` address here to set the value of the parameter, does
it all start to make sense? ;) Note that the same approach can be used for
any other parameter of the Faust object.

Let's run this and we should hear sound! Hooray!

That's not all folks! `faust2api` also allows you to make polyphonic DSP 
engines and since our Faust code is already declaring the standard `freq`, 
`gain`, and `gate` MIDI parameters, it is polyphony compatible. 

Let's go back to the online editor and export our code using the 
`api/android-poly` target.

Let's copy and paste the generated code into the Android app project as we did
before. In practice, you can just copy the `.cpp` file since the name and 
number of the parameters of the Faust object didn't change.

Sweet! Now instead of using `setParamValue` we can use the `keyOn()` or
`newVoice()` methods to instantiate a new voice. Wanna make a major triad?:

```
dspFaust.keyOn(70,100);
dspFaust.keyOn(74,100);
dspFaust.keyOn(77,100);
```

Easy! Note that as we did in session 1 a separate audio effect file can be
specified. We recommend you to check the `faust2api` doc to learn more about
that.

Have fun coding!

## Lesson 5: Structure of the Faust Ecosystem

The Faust ecosystem is pretty rich and varied. Many tools exist to write and
compile Faust code. In this lesson, we try to give you an overview of the
way Faust works in general and of the various tools that are associated to it.

[show slide 2]

The Faust compiler can be used under different forms: as a command line tool,
as a shared library, or as a JavaScript module. These last 2 cases allow 
for the embedding of the Faust compiler in other C++ projects or in web pages,
as it is done for the online editor. 

The Faust compiler can convert Faust code into various lower level languages
such as C, C++, JAVA, JavaScript, ASM JavaScript, WebAssembly, LLVM, and more. 

[show slide 3]

In the C++ case, the generated code can be placed in a wrapper (also called
architecture) that will turn it into a specific element such as an audio
plug-in, a standalone application, and more. That's basically how the export 
function of the online editor 
works: the Faust code is sent to a remote server, the corresponding C++ code is 
generated and embedded in an architecture file and the corresponding C++ file
is compiled and a binary object is returned. 

[show slide 4]

In the LLVM case, things are a bit different. Indeed, LLVM bit code is much
lower level than C++ and can be compiled to machine code on the fly,
which means that it allows to go straight from the Faust code to a binary
without going through C++. The shared library version of the Faust compiler
takes advantage of this feature to run Faust objects on the fly.

[show slide 5]

WebAssembly, JavaScript, and ASM JavaScript offer more or less the same type
of features and generated code can be compiled on the fly. This works
especially well with the JavaScript version of the Faust compiler. That's
basically the system that is used on the online editor: Faust code is compiled
with the JavaScript version of the Faust compiler, and the generated webassembly
code is fed directly intro a script processor node (or an Audio Worklet by the
time your watching this video) to be executed in the browser. 

[show slide 6]

Various more or less recent development tools based on these different versions 
of the Faust compiler are available. FaustWorks is the oldest Faust IDE and
it is based on the command line version of Faust. It allows us to edit Faust 
code, visualize its corresponding block diagram and compile it using one of the
targets installed on the system. 

[show slide 7]

FaustLive is a more recent tool embedding the shared library version of the 
Faust compiler offering the possibility to compile Faust code on the
fly using the LLVM backend.

[show URL: <http://faust.grame.fr/onlinecompiler/>]

[show screen capture: <http://faust.grame.fr/onlinecompiler/>]

The Faust online compiler can be seen as the ancestor of the online editor and
allows to edit Faust code directly in the web browser by getting access to most
of the features of the language using remote compilation. Unlike the online
editor, it doesn't embed the Faust compiler in the page and everything is done
remotely.

[show URL: <http://faust.grame.fr/faustplayground/>]

[show screen capture: <http://faust.grame.fr/faustplayground/>]

The online editor and the FaustPlayground are closed cousins as they both
host the JavaScript version of the Faust compiler and produce webassembly code 
to run Faust programs on the fly directly in the browser.

Then there's a whole collection of platform related tools embedding the Faust
compiler. For example, it is possible to write Faust code directly in Max,
CSOUND, SuperCollider, JUCE VST Plug-Ins, ChucK, and more. 

If the Faust command line compiler and associated tools are installed on your
system, you'll get access to the same functionalities than the online editor
but without having to connect to the internet. As mentioned earlier, even though
this will give you access to more features and more control on the generated
objects, it will require you to install the libraries and SDKs corresponding
to the Faust targets you want to use. Just to show you, the Faust compiler
can be called directly from the terminal to generate code and the Faust
architectures available in the export function of the online editor can be used
in the terminal through the various faust2 scripts installed on the system. 

[show screen capture: do it]

We purposely avoided these topics in this short course first because we believe that
the future is in the web and because we think that the online editor solves 
most of the platform related issues that we had in the past with Faust.

To conclude this lesson, we just want to say a brief word on Faust code editing
on a computer. Various code editors have syntax highlighting packages for Faust
such as emacs but we strongly recommend you to use Atom.

[show URL: <https://atom.io/>]

## Lesson 6: Using the C++ DSP Class Generated by Faust

The most basic way to use Faust is to generate C++ code. In this lesson, we 
briefly describe the structure of the DSP class generated by Faust and how it 
can be used in broader projects. 

Let say we want to add a reverb to an audio callback, we could write a simple
Faust program calling `dm.zita_light` that implements a nice feedback delay
network reverb. Remember again that we already used this circuit in session 1 and
that it hosts its own user interface.

[show screen capture: code]

```
import("stdfaust.lib");
process = dm.zita_light;
```

Let's call this program `reverb.dsp` and let's export it using the `source/C++`
target of the online editor. We should get a zip file in return containing
a file called `reverb.cpp`.

Let's open `reverb.cpp` in a text editor and see what's in there. 

[show screen capture: open reverb.cpp]

The `mydsp` class hosts a series of methods to get information about the DSP
object, to initialize it, or to run it. If we scroll down to the `public`
section of `mydsp`, the first method we'll find there is `metadata`. It allows
for the retrieval of the Faust metadata associated with the different files
imported or declared in the Faust code such as library names, licensing terms
and more.

You can retrieve the number of inputs and outputs of the object, here we have
a stereo input and a stereo output.

`init` should always be called after the `mydsp` class is instantiated and 
allows for the sampling rate to be set.

`buildUserInterface` takes a `UI` object as its main argument and passes it
the information about the various elements in the interface such as their names,
their associated metadata, their minimum and maximum values, and most 
importantly, the address of the pointer of the variable they're controlling. 
For example, `&fVslider1` points to the variable hosting the value of the
Dry/Wet parameter of the reverb.
 
Finally, the `compute` method is where all the magics happen. It basically 
implements our audio callback, therefore it should be called at each frame
period to process one complete buffer. It has 3 arguments: the size of the 
buffer to be processed, the input buffer as a double array, and the output
buffer as a double array. Note that the first dimension of these arrays
contains the various potential channels, and the second dimension the buffer
itself and its samples. 

If you look at the code in `compute`, you'll see that a for loop parses through
the samples of the buffers and computes the result.
