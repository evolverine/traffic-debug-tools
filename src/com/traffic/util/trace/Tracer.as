package com.traffic.util.trace {
    import avmplus.getQualifiedClassName;

    import com.adobe.cairngorm.contract.Contract;

    import flash.utils.Dictionary;

    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.logging.targets.TraceTarget;

    public class Tracer implements IObjectTracer {
        private var _tracerCache:ObjectTracerCache;

        public function Tracer(tracerCache:ObjectTracerCache)
        {
            _tracerCache = tracerCache;
        }

        public function trace(what:Object):String
        {
            return _tracerCache.getTracer(getQualifiedClassName(what)).trace(what);
        }

        public function register(classOfTracedObject:Class, tracer:Class):void
        {
            if(classOfTracedObject && tracer)
                _tracerCache.registerTracer(getQualifiedClassName(classOfTracedObject), tracer);
        }
    }
}
