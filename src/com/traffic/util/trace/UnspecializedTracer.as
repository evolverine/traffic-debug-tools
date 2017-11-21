package com.traffic.util.trace {
    public class UnspecializedTracer implements IObjectTracer {
        public function trace(what:Object):String
        {
            if(!what)
                return "null";

            var result:String = what.toString();
            if(result == "[object Object]")
            {
                var dynamicProperties:String = "";

                for (var property:String in what)
                    dynamicProperties += (dynamicProperties ? "; " : "") + property + ":\"" + what[property] + '"';

                if(dynamicProperties)
                result = "{" + dynamicProperties + "}";
            }
            return result;
        }
    }
}
