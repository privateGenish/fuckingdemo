# Demo Architecture

Creating a Demo architecture for our upcoming app.

The Demo will demonstrate:
* State Management solution using <b>Provider</b>
* Design Pattern using <b> MVVM
* Request and response handling

  

### Summery

The demo app will mimic the core UI element of the app, swiping, and the two main ideas: continuous swiping and group changing.

![App Demo](https://media0.giphy.com/media/sA2wYacT0U4TvwzLdr/giphy.gif?cid=790b7611b44c45b576ceaf2669fe4e42075d2ad268ef1ae0&rid=giphy.gif&ct=g)

* When running the app from a dead state it'll initialize the app with a ==Splash Page==
* Then the app will fetch data from the server with the ==Loading Page== 
* Each group has its own liked cards.
* To test the app response to error go to the `FakeServer` class and play with the `oddsToMakeAnError` variable

### MVVM
This example uses only one ViewModel and a few models to handle the various logic operations and types.