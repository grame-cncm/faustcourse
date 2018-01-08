## Lesson 2: Signals and Time Models

Informally, a signal is a value that changes over time, for example the 
variation of air pressure producing a sound. In other words, a signal is a 
function transforming a time input into a value output. This value is
also called a sample. 

The full scale audio range for samples is typically a floating-point value 
between -1 and +1. But of course, Faust can manipulate signals of arbitrary 
ranges that can also be integer signals.

[Slide 8: Signals and Time model]

If we give a name to this signal for example s, then s(t) represents the 
value of the signal s at time t. 

Now let's define time a more precisely. Since we are interested in sampled
signals (also called discrete signal), here time is an integer. A signal is 
infinite both in the future and in the past but the value of time is 0 when the
Faust program starts.
