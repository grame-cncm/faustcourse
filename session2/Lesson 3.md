## Lesson 3: Basic Faust Primitives

In this lesson, we're going to look at all the mathematical primitives of Faust.

### Numbers

Numbers and standard mathematical operations on numbers all have an equivalent 
on signals in Faust. For example, we already saw the `+` and the `abs` 
operations in lesson 1. 

Numbers in Faust are signal generators, elementary circuits with no input and
one output. In other words, a number in Faust produces an output signal whose 
samples are all equal to that number starting from time 0.

[Slide 9: Numbers are signal Generators] 

Note that the values of the samples of the signal produced by the number 1 in 
Faust are all 0 before time 0. 

### Arithmetic

All standard arithmetic operations can be carried out in Faust as shown on the
screen.

[Slide 10: Arithmetic Operations]

For instance, signals can be summed, subtracted, multiplied, raised to the 
power, divided, take the modulo of one signal by the other, TODO: cast.

### Comparison

All standard comparison operations are available in Faust.
But there is an important difference between comparing numbers and signals. 
The output produced by a comparison operator in Faust is also a signal. The
value of this signal is one when the comparison is true and 0 when the 
comparison is false. Because the result is also time dependent (it is a signal),
comparison operators in Faust must be considered as signal processors just like 
any other arithmetic operation.   

[Slide 11: Comparison Operations] + Faust example TODO

You can compare 2 signals to see when one is smaller than the other, smaller 
or equal, greater, greater or equal, equal, and different.

[Slide 12: Comparaison Semantics]

### Bitwise

As for arithmetic and comparison operations, most standard bitwise operations 
on integers are available in Faust. 

[Slide 13: Bitwise operations]

The `&`, `|`, and `xor` are typically used to combine the result of comparison
operations. The left and right shift operations are less commonly used but 
useful for specific cases when you want to manipulate the bit content of
samples. 

### Trigonometric

Most standard trigonometric operations can be carried out in Faust as shown on 
the screen.

[Slide 14: Trigonometric functions]

For instance, we can take the arc cosine of a signal, its arc sine, arc
tangent, arc tangent on 2 signals, cosine, sine, and tangent. 

### Log and Exponential

Bla bla

[Slide 15: Log and Exponential]

Bla bla

### Min, Max and other functions

Other mathematical operations are available as primitives in Faust as shown on
the screen.

[Slide 16: Min, Max and other functions]

Let's take a look at 2 very useful primitives: min and max. Min compares 2
input signals and always output the sample with the smallest value. Inversely
max compares 2 input signals and always output the sample with the greatest
value. 

[Slide 17: Max and Min semantics]

As an example, a simple dirty distortion effect can be implemented using these
2 primitives and a multiplication. Let's try to run it in the Faust online editor. 
WARNING: be careful if you're wearing as this might create feedback!

```
gain = hslider("gain",0.05,0,1,0.01);
process = *(100) : min(1) : max(-1) : *(gain);
```

The input signal is first multiplied by a 100 which corresponds to the drive 
parameter of the distortion. Then we hard-clip it between -1 and 1 using the
min and max primitives in series. It might seem counter-intuitive to use 1 with
min and -1 with max but that's right thing to do. Indeed, we want the minimum 
value between 1 and the input signal in order for the output signal to not 
exceed 1. Similarly, we want the maximum value between -1 and the input signal 
in order for the output signal to not be inferior to -1. 
