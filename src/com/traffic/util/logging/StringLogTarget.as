/**
 * Distributed under Apache License v2.0. For more information
 * see LICENSE.
 */

package com.traffic.util.logging {
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