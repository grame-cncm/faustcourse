## Lesson 3: Delays and tables
[Slide 27: Delays and Tables]

The primitives we have seen so far are essentially straight forward extensions
of mathematical operations on numbers to signals.

In this lesson we will see specific primitives that deal with time: delay lines (`mem`and `@`)
and read-only tables (`rdtable`) and read-write tables (`rwtable`).

### delay lines
Let's start with the delay lines:

[Slide 28: Delays semantics]

The primitive `mem` represents a 1-sample delay. The output signal is the input
signal delayed by 1 sample.

Please note that the first sample of the delayed signal is always zero. This is because in Faust,
by convention, the samples of any signal before time 0 are always 0: `x(t<0) = 0`

The primitive `@` is a more generale form. The first input signal is the signal to be delay, while the second input signal indicates the delay. Therefore we have `mem` equivalent to `_,1:@`

The example at the bottom of the slide shows the result of delaying a signal by a delay amount changing at every sample between 0 and 2.

Please note the delay amount must always be positive `x1(t) ≥ 0`. A negative delay would mean to look at the future of the delayed signal which is impossible in a rela-time system.

Let's write a very simple example where the signal 1 is delayed by 1 second (assuming a sampling of 44100)

```
process = 1, 44100 : @;
```

We you will run the program you will here a click after 1 second due to the signal rising from 0 to 1. You will ear another click when you stop the program (*** explain***)

There is a special notation to indicate a one sample delay : the apostrophe character (`'`).
For example `1'` means one delay by 1 sample and is equivalent to `1:mem` and `1,1:@`. (slide)

Using this notation we can produce a Dirac impulse, a signal that is always 0 except at time 0 where it is 1:

```
dirac = 1-1';
process = dirac;
```

When you run the program you will ear a click right at the beginning. As it will go back to 0 after 1 sample, you will not ear any click when you stop the program.

We can delay the Dirac impulse by 44100 samples:

```
dirac = 1-1';
process = dirac, 44100 : @;
```

You will now here a click after about 1 second (but no click when yu stop).


<< split into two lesson >>
### Read only table

[Slide 29: read only table semantics]

A read table takes three input signals. The first one is a constant signal that
defines the size of the table. The second one defines the content of the table.
The third input signal is the reading index in the table.

Let's do a simple example. We are going to fill a read only table with a dirac impulse and
read it using an periodic index signal from 0 to 4095. Note that the phase signal used as
reading index makes use of the tilde operator that we haven't seen yet.

```
dirac = 1-1';
phase = 1 : +~_ : &(4095);
process = 4096, dirac, phase : rdtable;
```

### Read-Write table

[Slide 30: read write table semantics]

A read-write table is an extension of the read only table with two extra input signals:
a write index and a signal to write in the table.

The first input signal is a constant signal that defines the size of the table. The second
one defines the initial content of the table. The third signal is the writing index in the table.
The fourth input signal is the signal to write into the table. The fifth and last input signal
is the reading index in the table.

At each instant `t `the content of the table is first modified by writing at index
index `x2(t)` the value of `x3(t)`. Then the table is read at index `x4(t)`.

The behaviour of read-write tables is a little bit complex. You will see a practical example
of use of the read-write table at the end of session 4.





