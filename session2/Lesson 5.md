## Lesson 5: UI Primitives
- buttons and sliders
- bargraphs
- groups
- attach

In this lesson we are going to see how user interfaces can be described in Faust. We have already seen some of user interface elements in lesson 3. But there are additional ones like bargraphs that are used to display values, or numerical entries. All these elements can be arranged vertically or horizontally using appropriate grouping schemes. Widgets and groups can be named using labels. These labels can contain additional information, called metadata, to customize their appearance or the way they are controlled.

[SLIDE 30: UI widgets]
On this slide you can see various kind of widgets. On the left side you have a button, a checkbox, and a numerical entry. On the center you can see a vertical slider. And on the right,you can find an horizontal slider, and horizontal bargraph and a vertical slider with a knob style.

### Buttons and checkbox
- As you can see, buttons and checkbox have only one parameter: a label. By default a button generate a signal that is 0. It rises to 1 when the user press the button and go back to 0 when it release it.

- Vertical and Horizontal sliders have five parameters: a label, a default value (the value of the widget when the program starts), a minimum value, a maximum value and a step value.
- A Bargraph has only three parameters: a label, a minimum value and a maximum value.

[SLIDE 31: Horiz and Vert groups]
When no group information are given, widgets are by default organized vertically. 

For example metadata can be used to map smartphones accelerometers, osc messages, midi messages



All these GUI elements produce signals. A button for example (see figure 3.8) produces a signal which is 1 when the button is pressed and 0 otherwise. These signals can be freely combined with other audio signals. 