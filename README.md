# traffic-debug-tools

traffic-debug-tools is a set of classes meant to help debug ActionScript / Flex applications. They are not meant to be used in production.

## Basic tracing
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
## Avoiding trace duplication for recurring events
```javascript
private function button1_clickHandler(event:MouseEvent):void
{
    tdt.debug("timer started!");
    timer.start();
}

private function onTimer(event:TimerEvent):void
{
    tdt.debugSimilar("timer!")
}
```
will output the following (once the application is idle)
```
==================================
[Main.___Main_Button1_click] -> [.button1_clickHandler]
==================================
	02:20.223 timer started!
==================================
[Timer.tick] -> [._timerDispatch] -> [Main.onTimer]
==================================
	02:20.338 timer!++++
```