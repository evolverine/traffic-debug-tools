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
```
will output the following (once the application is idle)
```
==================================
[Main.___Main_Button1_click] -> [.sayHello_clickHandler]
==================================
	49:54.979 hello, world
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
will output the following
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
The four + signs indicate that the same trace occurred 4 extra times.