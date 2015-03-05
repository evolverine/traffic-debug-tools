package com.traffic.util.trace {
    import com.adobe.cairngorm.contract.Contract;

    import mx.logging.ILogger;

    public class UnspecializedTracer implements IObjectTracer {
        public function trace(what:Object):String
        {
            return what + "";
        }
    }
}
