package com.traffic.util.trace {
    import avmplus.getQualifiedClassName;

    import com.adobe.cairngorm.contract.Contract;

    import flash.utils.Dictionary;

    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.logging.targets.TraceTarget;

    public class Tracer {
        private var _target:Object;
        private var _tracerCache:ObjectTracerCache;

        public function Tracer(objectToTrace:Object)
        {
            _target = objectToTrace;
            _tracerCache = new ObjectTracerCache();
        }

        public function trace():String
        {
            return _tracerCache.getTracer(getQualifiedClassName(_target)).trace(_target);
        }

        public function register(classNameOfTracedObject:String, tracer:Class):void
        {
            if(classNameOfTracedObject && tracer)
                _tracerCache.registerTracer(classNameOfTracedObject, tracer);
        }
    }
}
