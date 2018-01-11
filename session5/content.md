# Session 4: Advanced Sound Processing and Audio Effects

## Lesson 1: Distortion

```
import("stdfaust.lib");
distortion(drive,offset) = +(offset) : *(pregain) : clip : cubic : fi.dcblocker
with{
	pregain = pow(10,2*drive); // pregain range is 0 - 100
	clip = min(1) : max(-1); // clip the signal between 1 and -1
	cubic(x) = x - pow(x,3)/3;
};
d = hslider("drive",0,0,1,0.01) : si.smoo;
o = hslider("offset",0,-1,1,0.01) : si.smoo;
process = distortion(d,o);
```

## Lesson 2: Feedforward (One Zero) Filter

```
import("stdfaust.lib");
oneZero = vgroup("One Zero Filter",_ <: (_' : *(b1)),_ : +) 
with{
	b1 = hslider("b1",0,-1,1,0.01) : si.smoo;
};
process = oneZero;
```

## Lesson 3: Feedback Comb Filter

```
import("stdfaust.lib");
fComb = vgroup("Feedback Comb Filter",+~(@(delLength) : *(feedback)))
with{
  delLength = hslider("[0]Delay Length",1,0,100,1);
  feedback = hslider("[1]Feedback",0,0,1,0.01) : si.smoo;
};
process = fComb;
```
