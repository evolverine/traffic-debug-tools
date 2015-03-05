package com.traffic.util.trace {
    import com.adobe.cairngorm.contract.Contract;

    public class ObjectTracerCache {
        private static const _tracerFactory:ObjectTracerFactory = new ObjectTracerFactory();
        private static var _tracers:Array = [];
        private static var _defaultTracer:IObjectTracer;

        public function ObjectTracerCache()
        {
            _defaultTracer = new UnspecializedTracer();
        }

        public function getTracer(className:String):IObjectTracer
        {
            var result:IObjectTracer;

            if(!_tracers[className])
                _tracers[className] = _tracerFactory.create(className);

            result = _tracers[className] ? _tracers[className] as IObjectTracer : _defaultTracer;

            Contract.postcondition(result != null);
            return result;
        }

        public function registerTracer(classNameOfTracedObject:String, tracerClass:Class):void
        {
            _tracerFactory.registerTracer(classNameOfTracedObject, tracerClass);
        }
    }
}
