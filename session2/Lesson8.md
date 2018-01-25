
## Lesson 8 : User Defined Function

Welcome to lesson 8. In this last lesson we are going into more details regarding function definitions.


### Function definitions and lambda expressions

Definitions can have formal parameters to create user defined functions.
Let's take an example:

[**demo**]

    import("stdfaust.lib");
    wave = 440/ma.SR : (+, 1 : fmod) ~ _;
    process = wave * hslider("gain", 0, 0, 1, 0.01);

In this example wave has a fixed frequency of 440 Hz. But we would like to have a more general definition with a frequency parameter that we can specify when we use wave.

[**demo**]

    import("stdfaust.lib");

    wave(f) = f/ma.SR : (+, 1 : fmod) ~ _;
    process = wave(440) * hslider("gain", 0, 0, 1, 0.01);

Please note that this is equivalent to :

[**demo**]

    import("stdfaust.lib");

    wave    = \(f).(f/ma.SR : (+, 1 : fmod) ~ _);
    process = wave(440) * hslider("gain", 0, 0, 1, 0.01);

where the expression `\(f).(f/ma.SR : (+, 1 : fmod) ~ _)` is called a lambda expression. You can think of a lambda expression has an anonymous function. Lambda expressions can be used directly as in the following example:

[**demo**]

    import("stdfaust.lib");

    process = \(f).(f/ma.SR : (+, 1 : fmod) ~ _)(440) * hslider("gain", 0, 0, 1, 0.01);

Let's do a more involved function example. We would like to create a function taking a monophonic effect and adding a dry/wet control.

[**demo**]

    import("stdfaust.lib");

    echo(d,f) = + ~ (@(d) : *(f));
    drywet(fx) = _ <: _, fx : *(1-w) , *(w) :> _
        with {
            w = vslider("dry-wet[style:knob]", 0.5, 0, 1, 0.01);
        };

    process = button("play") : pm.djembe(60, 0.3, 0.4, 1) : drywet(echo(44100/4, 0.75));

The drywet function is an example of higher order function. It takes a circuit as a parameter and build a new circuit around it.

### pattern matching expressions

Pattern matching is a very powerful mechanism to algorithmically generate Faust circuits.
Let's say that you want to describe a function to duplicate an circuit several times in parallel:

[**demo**]

    duplicate(1,x) = x;
    duplicate(n,x) = x, duplicate(n-1,x);

    process = duplicate(5,0) : duplicate(5,_) :> _


Please note that this last definition is a convenient alternative to the more verbose :

[**demo**]

    duplicate = case {
                (1,x) => x;
                (n,x) => duplicate(n-1,x);
                };

Here is another example to count the number of elements of a list. Please note that we simulate lists using parallel composition : (1,2,3,5,7,11). The main limitation of this approach is that there is no empty list. Moreover lists of only one element are represented by this element :

[**demo**]

    duplicate(1,x) = x;
    duplicate(n,x) = x, duplicate(n-1,x);

    count((x,xs)) = 1+count(xs);
    count(x) = 1;

    process = count(duplicate (5, 0));


Please note that the order of pattern matching rules matters. The more specific rules must precede the more general rules.

Here is a more involved example. We would like to create a reverse echo where echo increases in volume instead of decreasing. We can't use a simple feedback loop like for the regular echo, but we can build the circuit algorithmically using pattern matching

[**demo**]

    import("stdfaust.lib");

    revecho (N,d,a) = _ <: R(N,0) :> _
        with {
            R(0,m) = echo(d*m,0);
            R(n,m) = echo(d*m,a^n), R(n-1,m+1);
            echo(d,a) = @(d) : *(a);
        };

    process = button("play") : pm.djembe(60, 0.3, 0.4, 1) : revecho(8, ma.SR/10, 0.7);

### iterations

Faust offers a set of predefined iterators: `seq`, `par`, `sum` and `prod`. You can think of these iterators as some kind of for loops that can be used to build complex circuits.

An iterator takes 3 parameters. The first one is the name of a variable, then we have the number of iterations, and finally the expression we want to iterate on.

Let's do a simple equalizer by placing in sequence 5 peak equalizers

[**demo**]

    declare name "equalizer";
    import("stdfaust.lib");
    peakeq (f) = hgroup("band %f",
                            fi.peak_eq_cq(level,f,Q)
                            with {
                                level = vslider("level[unit:dB][style:knob]", 0, -70, 12, 1);
                                Q = vslider("Q[style:knob]", 1, 1, 100, 0.01);
                            }
                        );
    process  =	no.noise : hgroup("Equalizer", seq(i, 5, peakeq(500+500*i)));


This example concludes the Lesson 8 and Session 2




