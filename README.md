# traffic-debug-tools

traffic-debug-tools is a set of classes meant to help debug ActionScript / Flex applications. They are not meant to be used in production.

## Tracing
Here are the problems which traffic-debug-tools aims to solve when debugging applications via traces:
* The need to visually interpret the ugly stack trace you get from `new Error().getStackTrace()`.
* The information overload you get from multiple traces which include the stack trace.
* The trace overload you get when tracing during unexpectedly frequent events, which then obscures the traces you care about.

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
	07:59.789 hello world!
	07:59.797 anyone home?
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