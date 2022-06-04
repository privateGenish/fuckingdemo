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

## stateManagemet method
the mvvm architecture binding with the stateManagement pattern.
the stateManagement logic is : the viewModel live above all the widget, that way give us the ability to access the viewModel from any place on the widget tree. 

the logic of update the ui is as follow (we will demonstrate on the HomePage() widget ):

1 - generate enum in ViewModel 
=>  enum HomePageState {loading , error , data , dataReady} .

2 - declare a enum var in ViewModel
=>  declare _homePageState in ViewModel and get function, to get 
always the latest value of _homePageState .

3 - initial the enum var at the ViewModel lunching.
=> give to _homePageState initial value, 
  _homePageState = HomePageState.loading.

4 - manage the enum var in viewModel and notifyListnets after the changing .
=> change the value of the enum var.
 for example,after the getUser() is done.
 getUser() async {
     await http.getUser
     _homepageState = HomePageState.dataReady
     notifyListenrs()
 }

5 - wrap a widget with selector which only listen to the enum var type and use switch case in the widget.
=>  
Selector<ViewModel,HomePageState>(
    selector: (_,userModel) => userModel.homePageState
    builder: (context,homePageState,child){
        switch(homePageState){
            case HomePageState.loading :
            {
                return Loading()
            }
            case HomePageState.dataReady : {
                return ShowUI
            }
        }
    }
)  


#this logic provide us a fine controll on the ui and easy way to understand the code
