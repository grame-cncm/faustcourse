# Session 4 - Assignment

## Exercise 1: Shred It!

The goal of this exercise is to reuse the Karplus-Strong example from Lesson 4 
to implement a simple harp where the strings can be strummed using a slider.

As a first step, you should put multiple strings in parallel using the `par`
iteration operator. The following meta Faust code should give you and idea of
how to do that:

```
nStrings = 6
harp = par(i,nStrings,(gate : string)) :> _;
```

where `nStrings` is the number of strings.

Then, the signal of a slider should be compared to a number to trigger each
independent string:

```
strum = hslider("strum",0,0,5,1) <: par(i,nStrings,(gate : string)) :> _;
```

In this meta code, the button in `gate` should be replaced by a comparison
using the `i` counter coming from `par`.

You should submit a Faust code implementing a harp where strings can be 
strummed using a single slider. Feel free to use as many strings as you want
(as long as your computer can handle them) and to create any interface. For
example, you could choose the pitch of each string independently or you could
have selectable chords, etc.: your call!

## Exercise 2: Using Effects From the Libraries

The goal of this exercise is to force you to look into the source code of the
Faust libraries (available in the `/libraries` folder of TODO).

First, explore the various effects from `demos.lib` 
(<http://faust.grame.fr/library.html#effects-1>) and see how you can combine
some of them with the looper implemented in Lesson 5 to generate crazy sounds.

Once you have an idea of the ones you'd like to use, look at their definition
in the source of `demos.lib` and break them apart to implement your own
user interface to replace the built-in one. For example, `dm.phaser2_demo`
is based on `pf.phaser2_stereo`, so `pf.phaser2_stereo` is the function you'd
want to use in your submission.

The whole idea here is to simplify the exhaustive interface of the circuits
implemented in `demos.lib` to only keep the part that you want the user to
control.

You should submit a Faust file based on the looper from Lesson 5 and adding
at least one effect to it. You should spend some time thinking about the 
overall design of the interface. Try to make it as efficient as possible.
Feel free to get rid of `dm.zita_light` if necessary.



