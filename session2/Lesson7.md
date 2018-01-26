
## Lesson 7: Faust programs

In this lesson we will see in more details how faust programs are organized. Most of the programs we have seen so far were made of a very few lines of code. But for larger programs we want to better structure our code.


### Programs and Statements
The first thing to know is that a Faust program is a list of statements. The statements of a Faust program are of four kinds :
- metadata declarations,
- file imports,
- definitions
- and documentation.
All statements but documentation end with a semicolon (;). We will not look at documentation statements. But if you are curious about the automatic documentation system you can look at chapter 11 of the Faust Quick Reference.



### Metadata Declarations
Meta-datadeclarations (for example `declare name "noise";`) are optional and typically used to document a Faust project, or to pass information to the architecture files. All these declarations will be embedded into the generated code with a mechanism for the surrounding program to retrieve this information.

Common declarations are for example:

    declare name "SuperFx";
    declare author "Alan Turing";
    declare copyright "Stanford University";
    declare license "GPL 3";

It is a good habit to have these declared in you code

Declarations can be used also to pass information to the architecture file. For example when you are creating smartkeyboard applications you can give an abstract description of the keyboard user interface to be generated:

    declare interface "SmartKeyboard {
	    'Number of Keyboards':'1',
	    'Keyboard 0 - Number of Keys':'1',
	    'Keyboard 0 - Piano Keyboard':'0',
	    'Keyboard 0 - Static Mode':'1',
	    'Keyboard 0 - Send X':'1',
	    'Keyboard 0 - Send Y':'1'
    }";


### Definition
Definitions, like `process = +;` are the most common statements. A valid Faust program must have at least a definition of `process` which is the entry point of the program so to speak. If you are familiar with `C/C++` you can think of `process` as the analog of `main`.

Definitions are essentially a convenient shortcut avoiding to type long expressions. During compilation, more precisely during the evaluation stage, identifiers are replaced by their definitions. It is therefore always equivalent to use an identifier or directly its definition.

The order of definitions doesn't matter in Faust (the only exception is when defining pattern matching rules). But redefinitions are not allowed.

We will come back to definitions in more details later in the lesson...


### Environments

Environments are a way to group related definitions together in a separate dictionary. Environments are also a convenient way to avoid potential name conflicts in large programs with many definitions. They have somehow the same goal as namespaces in C++.

Let say we would like to group together several constants to reuse them later. We can write the following program:

[**demo**]

    myconst = environment {
        PI = 3.14159265359;
        e = 2.71828182846;
    };

    process = myconst.e;

### With
Environments local to an expression can be create using the `with {}` construction. You will often find this construction in Faust programs.

[**demo**]

    import("stdfaust.lib");

    pingpong(d,f) = echo(2*d,f) <: _, @(d)
        with {
            echo(d,f) = + ~ (@(d) : *(f));
        };

    process = button("play") : pm.djembe(60, 0.3, 0.4, 1) : pingpong(44100/4, 0.75);


### File imports

File imports allow to import definitions from other source files. Most Faust programs start with importing the "stdfaust.lib" library.

[**demo**]

    import("stdfaust.lib");

A Faust library itself is just a file with Faust code. The `import` statement  adds all the definitions of the imported file into the current program as if they were typed directly into the progam. (like an include in C or C++)

By convention Faust programs have the `.dsp` extension, while Faust libraries have the `.lib` extension. The main difference between a Faust program and a Faust library is that a library doesn't define `process`.

### library("filename")
If we look inside `stdfaust.lib` we can see that it imports in turn all the standard libraries using a bunch of `library("filename")` expressions.

[**demo**]

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
