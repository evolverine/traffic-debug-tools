# traffic-debug-tools

traffic-debug-tools is a set of classes meant to help debug ActionScript / Flex applications. They are not meant to be used in production.

## Basic tracing
```actionscript
tdt.debug("hello, world");
```
will output
```
==================================
[Main.___Main_Button1_click] -> [.button1_clickHandler]
==================================
	49:54.979 hello, world
```

\=\=\=
\===