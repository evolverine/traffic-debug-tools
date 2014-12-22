# traffic-debug-tools

traffic-debug-tools is a set of classes meant to help debug ActionScript / Flex applications. They are not meant to be used in production.

## Tracing
Here are the problems which traffic-debug-tools aims to solve when debugging applications via traces:
* The need to visually interpret the ugly stack trace you get from `new Error().getStackTrace()`.
* The information overload you get from multiple traces which include the stack trace.
* The trace overload you get when tracing during unexpectedly frequent events, which then obscures the traces you care about.
* The difficulty of monitoring the changes to Arrays

### Basic tracing

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

### Avoiding trace duplication for recurring events

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

### Tracing easy-to-read stack trace

```javascript
trace("where am I: " + tdt.whereAmI());
```

will output

```
where am I: [LayoutManager.doPhasedInstantiationCallback] -> [.doPhasedInstantiation] -> [UIComponent.set initialized] -> [.dispatchEvent] -> [EventDispatcher.dispatchEvent] -> [.dispatchEventFunction] -> [Test.___Test_WindowedApplication1_creationComplete] -> [.creationCompleteHandler]
```

### Monitoring changes to Arrays
If there's an `ArrayCollection` or a `ListCollectionView` instance which you need to monitor for changes, during debugging you can easily extend its class and inject your debug statements in `addItemAt()`, `removeItem()`, etc. However, with `Array`s it's more tricky, which is what `InspectableArray` helps you solve. Change this:

```
private var arrayYouWantToMonitor:Array = [];
```

into

```
private var arrayYouWantToMonitor:InspectableArray = new InspectableArray();
```

From this point onward every time an item is pushed or popped from the array you get a log trace such as:

```
[trace] ==================================
[trace] [LayoutManager.doPhasedInstantiationCallback] -> [.doPhasedInstantiation] -> [UIComponent.set initialized] -> [.dispatchEvent] -> [EventDispatcher.dispatchEvent] -> [.dispatchEventFunction] -> [Test.___Test_WindowedApplication1_creationComplete] -> [.creationCompleteHandler] -> [InspectableArray.push]
[trace] ==================================
[trace] 	45:01.192 push: hello world!
```

If you need to, you can easily extend more functions, such as `join()` or `filter()`, you can do so directly in `InspectableArray`, or in your own class which extends `InspectableArray`.