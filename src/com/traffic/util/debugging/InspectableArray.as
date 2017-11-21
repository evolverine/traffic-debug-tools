package com.traffic.util.debugging
{
	public dynamic class InspectableArray extends Array
	{
        private var _makeSubArraysInspectable:Boolean = false;

		public function InspectableArray(...parameters)
		{
			super();
			
			var i:int;
			if(parameters.length == 1)
			{
				for (i = 0; i < parameters[0]; i++) 
					this[i] = "";
			}
			else if(parameters.length > 1)
				this.push.apply(parameters);
		}
		
		override AS3 function push(...rest):uint
		{
            if(_makeSubArraysInspectable)
                replaceArraysWithInspectableArrays(rest);

			tdt.debug("push: " + rest, "");

			return super.push.apply(this, rest);
		}

        override AS3 function pop():*
        {
            var poppedItem:* = super.pop();
			tdt.debug("pop: " + poppedItem, "");
            return poppedItem;
        }

        override AS3 function splice(...args:Array):*
		{
			const where:int = args.length ? args[0] as int : NaN;
			var numDeletions:int = args.length >= 2 ? args[1] as int : 0;
			if(numDeletions < 0)
				numDeletions = 0;
			const newItems:Array = args.length >= 3 ? args.slice(2) : null;

			if(_makeSubArraysInspectable)
				replaceArraysWithInspectableArrays(args);

			tdt.debug("splicing at position " + where + ((numDeletions > 0) ? ". Deleting " + numDeletions + " items." : "") + ((newItems && newItems.length) ? (" Adding these items: " + newItems) : ""));

            return super.splice.apply(this, args);
		}

        private function replaceArraysWithInspectableArrays(array:Array):Array
        {
			function detectAndReplaceArray(item:*, index:int, array:Array):void
			{
				if(item is Array)
                {
					tdt.debug("replacing array [" + item + "] with equivalent InspectableArray." )
                    array.splice(index, 1, InspectableArray.fromArray(item as Array));
                }
			}

			var result:Array = [];

			if(array)
				array.forEach(detectAndReplaceArray, this);

			return result;
        }

		public static function fromArray(source:Array):InspectableArray
		{
			var result:InspectableArray = new InspectableArray();
			for(var s:String in source)
			{
				result[s] = source[s];
			}
			return result;
		}

        public function get makeSubArraysInspectable():Boolean
        {
            return _makeSubArraysInspectable;
        }

        public function set makeSubArraysInspectable(value:Boolean):void
        {
            _makeSubArraysInspectable = value;
        }
    }
}