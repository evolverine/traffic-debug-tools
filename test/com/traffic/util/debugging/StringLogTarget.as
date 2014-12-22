package com.traffic.util.debugging {
    import mx.logging.AbstractTarget;
    import mx.logging.LogEvent;

    public class StringLogTarget extends AbstractTarget {
        private var _logString:String = "";

        override public function logEvent(event:LogEvent):void
        {
            _logString += event.message;
        }

        public function get log():String
        {
            return _logString;
        }
    }
}