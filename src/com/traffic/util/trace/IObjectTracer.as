package com.traffic.util.trace {
    import mx.logging.ILogger;

    public interface IObjectTracer {
        function trace(what:Object):String
    }
}
