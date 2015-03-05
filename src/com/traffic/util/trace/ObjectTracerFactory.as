package com.traffic.util.trace {
    import com.adobe.cairngorm.contract.Contract;

    public class ObjectTracerFactory {
        private static const _tracerDefinitions:Array = [];
        {
            _tracerDefinitions["mx.collections::HierarchicalCollectionView"] = HierarchicalCollectionViewTracer;
        }

        public function create(className:String):IObjectTracer
        {
            if(_tracerDefinitions[className])
                return new _tracerDefinitions[className]();

            return null;
        }

        public function registerTracer(classNameOfTracedObject:String, tracerClass:Class):void
        {
            Contract.precondition(classNameOfTracedObject != null && classNameOfTracedObject != "");
            Contract.precondition(tracerClass != null);

            _tracerDefinitions[classNameOfTracedObject] = tracerClass;
        }
    }
}
