# traffic-debug-tools

traffic-debug-tools is a set of classes meant to help debug ActionScript / Flex applications. They are not meant to be used in production.

## Tracing
Here are the problems which traffic-debug-tools aims to solve when debugging applications via traces:
* The need to visually interpret the ugly stack trace you get from `new Error().getStackTrace()`.
* The information overload you get from multiple traces which include the stack trace.
* The trace overload you get when tracing during unexpectedly frequent events, which then obscures the traces you care about.
* The difficulty of monitoring the changes to Arrays
* The paucity of toString() for many types of objects

### Tracing easy-to-read stack traces

```javascript
trace("where am I: " + tdt.whereAmI());
```

will output

```
where am I: [LayoutManager.doPhasedInstantiationCallback] -> [.doPhasedInstantiation] -> [UIComponent.set initialized] -> [.dispatchEvent] -> [EventDispatcher.dispatchEvent] -> [.dispatchEventFunction] -> [Test.___Test_WindowedApplication1_creationComplete] -> [.creationCompleteHandler]
```

### Basic debug tracing

```javascript
tdt.debug("hello, world");
tdt.debug("anyone home?");
```

will output the following (once the application is idle)

```
==================================
[LayoutManager.doPhasedInstantiationCallback] -> [.doPhasedInstantiation] -> [UIComponent.set initialized] -> [.dispatchEvent] -> [EventDispatcher.dispatchEvent] -> [.dispatchEventFunction] -> [Test.___Test_WindowedApplication1_creationComplete] -> [.creationCompleteHandler]
==================================
	01:02.827 hello world!
	01:02.842 ...anyone home?
```

The part inside the equal signs is the stack trace, and beneath it there's the trace, including a timestamp.
Note that the stack trace doesn't contain the class name for some functions. That's because they share it with the previous function, so it's easier to read without it. (This can be turned off via a call to ```tdt.setUp(false, false);```.

### Avoiding duplication of recurring traces

```javascript
private function startTimer_clickHandler(event:MouseEvent):void
{
    tdt.debug("timer started!");
    timer.start();
}

private function onTimer(event:TimerEvent):void
{
    tdt.debugSimilar("timer!")
}
```

will output

```
==================================
[Main.___Main_Button1_click] -> [.startTimer_clickHandler]
==================================
	02:20.223 timer started!
==================================
[Timer.tick] -> [._timerDispatch] -> [Main.onTimer]
==================================
	02:20.338 timer!++++
```

The four + signs indicate that the same trace occurred four extra times (i.e. five times in total).

### Tracing detailed information about objects
Sometimes you need more information about certain types of objects than toString() will give you. In this case, you either use the out-of-the-box object tracers (currently just HierarchicalCollectionViewTracer) or create your own.
```javascript
trace(tdt.traceObject(advancedDataGrid.dataProvider as HierarchicalCollectionView));
```

will output something like

```
Planning
Engineering
Implementation
```

To create your own tracer, simply create a class that implements ```IObjectTracer``` (e.g. ```InvoiceVOTracer```) and add it to ```tdt``` like this:
```javascript
class InvoiceVOTracer implements IObjectTracer
{
    public function trace(what:Object):String
    {
        var invoice:InvoiceVO = what as InvoiceVO;
        return invoice ? invoice.number + "-" + invoice.company : "<null>";
    }
}
```

then, separately:

```javascript
tdt.registerNewObjectTracer(InvoiceVO, InvoiceVOTracer);
```

Now you can see the details of any invoice like this:

```javascript
tdt.debug(tdt.traceObject(invoiceVO));
```

### Monitoring changes to Arrays
If there's an `ArrayCollection` or a `ListCollectionView` instance which you need to monitor for changes, during debugging you can easily extend its class and inject your debug statements in `addItemAt()`, `removeItem()`, etc. However, with `Array`s it's more tricky, which is what `InspectableArray` helps you solve. Change this:

```javascript
private var arrayYouWantToMonitor:Array = [];
```

into

```javascript
private var arrayYouWantToMonitor:InspectableArray = new InspectableArray();
```

From this point onward every time an item is pushed or popped from the array you get a log trace such as:

```
==================================
[LayoutManager.doPhasedInstantiationCallback] -> [.doPhasedInstantiation] -> [UIComponent.set initialized] -> [.dispatchEvent] -> [EventDispatcher.dispatchEvent] -> [.dispatchEventFunction] -> [Test.___Test_WindowedApplication1_creationComplete] -> [.creationCompleteHandler] -> [InspectableArray.push]
==================================
	45:01.192 push: hello world!
```

If you need to, you can easily extend more functions, such as `join()` or `filter()`. You can do so directly in `InspectableArray`, or in your own class which extends `InspectableArray`.

### Dispatching and using debugging events
*Problem*: when an event occurs you'd like to trace the state of other, inaccessible data. For instance, when the user changes the product price in a grid editor, you'd like to trace the value of the minimum allowed price (stored in UserSettingsModel.as, which you cannot access from the editor).

Without traffic-debug-tools you could create, say, TempGlobalsForDebugging.as, then make sure it contains the value of the minimum price, and then trace it when the user changes a price in the grid. Another option could be to dispatch a bubbling event when the user changes a value, and catch it somewhere you have access to all the data (say in the main application file), and trace it there.

This can be cumbersome and time consuming because in a high level class you need to jump through many hoops to access the user setting. It's also potentially buggy, because the event could be cancelled at any point in its bubbling by existing user code.

With tdt there's a simpler *solution*: you dispatch an event from anywhere you want, and handle it anywhere else, in as many places as you need. This means that you always have easy access to the data you want to trace.

```javascript
//in ProductPriceRenderer.mxml
private function onPriceChange(event:FlexEvent):void
{
	product.price = priceField.value; //this code was already there
	tdt.dispatchEvent(new EventWithData("priceChange", priceField.value));
}

//in UserSettingsModel.as
public function UserSettingsModel()
{
	tdt.addEventListener("priceChange", onPriceChanged);
}

private function onPriceChanged(event:EventWithData):void
{
	var newPrice:Number = event.data as Number;
	tdt.debug("new price: " + newPrice + " is larger than minimum price: " + (newPrice < this.minimumPrice));
}
```

### Enabling and disabling traces
Sometimes, to remove trace noise, you want to disable all ```tdt``` traces until an event occurs, and then re-enable them.

```javascript
private function onCreationComplete(event:FlexEvent):void
{
	tdt.disable();
}

private function onUserIsInBuggySection(event:Event):void
{
	tdt.enable();
}
```
Make sure you remember to re-enable traces, because otherwise it might look like nothing interesting is happening, when it's actually because traces are disabled.