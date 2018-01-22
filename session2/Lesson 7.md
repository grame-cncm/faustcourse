## Lesson 7: Faust programs

In this lesson we will see in more details how faust programs are organized. Most of the programs we have seen so far where made of very few lines of code. But for larger programs we want to structure our code.


### Programs and Statements
The first thing to know is that a Faust program is a list of statements. The statements of a Faust program are of four kinds :
- metadata declarations,
- file imports,
- definitions
- and documentation.
All statements but documentation end with a semicolon (;). We will not look at documentation statements. But if you are curious about the automatic documentation system you can look at chapter 11 of Faust Quick Reference.



### Metadata Declarations
Meta-datadeclarations (for example `declare name "noise";`) are optional and typically used to document a Faust project, or to pass information to the architecture files. All these declarations will be embedded into the generated code with a mechanism for the surrounding program to retrieve this information.

Common declarations are for example:

    declare name "SuperFx";
    declare author "Alan Turing";
    declare copyright "Stanford University";
    declare license "GPL 3";

It is a good habit to have these declare in you code

Declaration can be used also to pass information to the architecture file. For example when you are creating smartkeyboard application you can give an abstract description of the keyboard user interface to be generated:

    declare interface "SmartKeyboard {
	    'Number of Keyboards':'1',
	    'Keyboard 0 - Number of Keys':'1',
	    'Keyboard 0 - Piano Keyboard':'0',
	    'Keyboard 0 - Static Mode':'1',
	    'Keyboard 0 - Send X':'1',
	    'Keyboard 0 - Send Y':'1'
    }";


### Definition
Definitions, like `process = +;` are the most common statements. A valid Faust program must a least have a definition of `process`, the entry point of the program so to speak. If you are familiar with `C/C++` you can think of `process` as the analog of `main`.

Definitions are essentially a convenient shortcut avoiding to type long expressions. During compilation, more precisely during the evaluation stage, identifiers are replaced by their definitions. It is therefore always equivalent to use an identifier or directly its definition.

The order of definition doesn't matter in Faust (the only exception is when defining pattern matching rule). But redefinitions are not allowed.

We will come back to definitions in more details later in the lesson...


### Environments

Environments are a way to group related definitions together in a separate dictionnary. Environment are also a convenient way to avoid potential conflict of names in large programs with many definitions. They have somehow the same goal as namespaces in C++.

Let say we would like to group together several constants for later reuse. We can write the following program:

    myconst = environment {
        PI = 3.14159265359;
        e = 2.71828182846;
    };

    process = myconst.e;

### With
Environments local to an expression can be create using the `with {}` construction. You will often find this construction in Faust programs.

    import("stdfaust.lib");

    pingpong(d,f) = echo(2*d,f) <: _, @(d)
        with {
            echo(d,f) = + ~ (@(d) : *(f));
        };

    process = button("play") : pm.djembe(60, 0.3, 0.4, 1) : pingpong(44100/4, 0.75);


### File imports

File imports allow to import definitions from other source files. Most Faust programs starts with importing the "stdfaust.lib" library.

    import("stdfaust.lib");

A Faust library itself is just a file with Faust code. The `import` statement that adds all the definitions of the imported file into the current program as if they where typed directly into the progam.

By convention Faust programs have the `.dsp` extension, while Faust libraries have the `.lib` extension. The main difference between a Faust program and a Faust library is that a library doesn't define `process`.

### library("filename")
If we look inside `stdfaust.lib` we can see that it in turn imports all the standard libraries using a bunch of `library("filename")` expressions.

    an = library("analyzers.lib");
    ba = library("basics.lib");
    co = library("compressors.lib");
    de = library("delays.lib");
    dm = library("demos.lib");
    dx = library("dx7.lib");
    en = library("envelopes.lib");
    fi = library("filters.lib");
    ho = library("hoa.lib");
    ma = library("maths.lib");
    ef = library("misceffects.lib");
    os = library("oscillators.lib");
    no = library("noises.lib");
    pf = library("phaflangers.lib");
    pm = library("physmodels.lib");
    re = library("reverbs.lib");
    ro = library("routes.lib");
    sp = library("spats.lib");
    si = library("signals.lib");
    sy = library("synths.lib");
    ve = library("vaeffects.lib");
    sf = library("all.lib");

`import` and `library` are somehow similar, as already explained `import` adds all the definitions of the imported file into the current program, while `library` creates an environment and imports all the definition in that environment.


### Function definitions and lambda expressions

Definitions can have formal parameters to create user defined functions.
Let's take an example:

    import("stdfaust.lib");
    wave = 440/ma.SR : (+, 1 : fmod) ~ _;
    process = wave * hslider("gain", 0, 0, 1, 0.01);

In this example wave has a fixed frequency of 440 Hz. But we would like to have a more general definition with a frequency parameter that we can specify when we use wave.

    import("stdfaust.lib");

    wave(f) = f/ma.SR : (+, 1 : fmod) ~ _;
    process = wave(440) * hslider("gain", 0, 0, 1, 0.01);

Please note that this is equivalent to :

    import("stdfaust.lib");

    wave    = \(f).(f/ma.SR : (+, 1 : fmod) ~ _);
    process = wave(440) * hslider("gain", 0, 0, 1, 0.01);

where the expression `\(f).(f/ma.SR : (+, 1 : fmod) ~ _)` is called a lambda expression. You can think of a lambda expression has an anonymous function. Lambda expressions can be used directly as in the following example:

    import("stdfaust.lib");

    process = \(f).(f/ma.SR : (+, 1 : fmod) ~ _)(440) * hslider("gain", 0, 0, 1, 0.01);

Let's do a more involved example of function. We would like to create a fiunctionthat takes a monophonic effet and adds a dry/wet control.

    import("stdfaust.lib");

    echo(d,f) = + ~ (@(d) : *(f));
    drywet(fx) = _ <: _, fx : *(1-w) , *(w) :> _
        with {
            w = vslider("dry-wet[style:knob]", 0.5, 0, 1, 0.01);
        };

    process = button("play") : pm.djembe(60, 0.3, 0.4, 1) : drywet(echo(44100/4, 0.75));

The drywet function is an example of higher order function. It takes a circuit as a parameter and build an additional circuit around it.

### pattern matching expressions

Pattern matching is a very powerful mechanism to algorithmically generate Faust expressions.
Let's say that you want to describe a function to duplicate an expression several times in parallel:

    duplicate(1,x) = x;
    duplicate(n,x) = x, duplicate(n-1,x);

    process = duplicate(5,0) : duplicate(5,_) :> _


Please note that this last definition is a convenient alternative to the more verbose :

    duplicate = case {
                (1,x) => x;
                (n,x) => duplicate(n-1,x);
                };

Here is another example to count the number of elements of a list. Please note that we simulate lists using parallel composition : (1,2,3,5,7,11). The main limitation of this approach is that there is no empty list. Moreover lists of only one element are represented by this element :

    duplicate(1,x) = x;
    duplicate(n,x) = x, duplicate(n-1,x);

    count((x,xs)) = 1+count(xs);
    count(x) = 1;

    process = count(duplicate (5, 0));


Please note that the order of pattern matching rules matters. The more specific rules must precede the more general rules.

Here is a more involved example. We would like to create a reverse echo where echo increase in volume instead of decreasing. We can't use a simple feedback loop like for the regular echo, but we can build the circuit algorithimically using pattern matching

    import("stdfaust.lib");

    revecho (N,d,a) = _ <: R(N,0) :> _
        with {
            R(0,m) = echo(d*m,0);
            R(n,m) = echo(d*m,a^n), R(n-1,m+1);
            echo(d,a) = @(d) : *(a);
        };

    process = button("play") : pm.djembe(60, 0.3, 0.4, 1) : revecho(8, ma.SR/10, 0.7);

### iterations
Faust offers a set of predefined iterators: `seq`, `par`, `sum` and `prod`.

let's do a simple equalizer

    import("stdfaust.lib");
    process  =	hgroup("equalizer",
                    seq(i, 5,
                        hgroup("band %i",
                            fi.peak_eq_cq(level,fx,Q)
                            with {
                                level = vslider("level[unit:dB][style:knob]", 0, -70, 12, 1);
                                fx = 500 + i * 500;
                                Q = vslider("Q[style:knob]", 0.5, 0.1, 1, 0.01);
                            }
                        )
                    )
                );


### expressions

```
// random  = (_,12345:+) ~ (_,1103515245:*);    // core syntax
// random  = _+12345 ~ _*1103515245;            // infix notation
// random  = +(12345) ~ *(1103515245);          // prefix notation

random  = +(12345) ~ *(1103515245);

noise   = random/2147483647.0;

process = noise * vslider("Volume[style:knob]", 0, 0, 1, 0.1) <: _,_;

```







