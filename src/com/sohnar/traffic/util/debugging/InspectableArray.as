package com.sohnar.traffic.util.debugging
{
	import mx.collections.CursorBookmark;

	public dynamic class InspectableArray extends Array
	{
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
			if(rest.length == 1 && rest[0] is CursorBookmark)
				ErrorUtils.debug("push: " + CursorBookmark(rest[0]).value, new Error().getStackTrace(), true);
			else
				ErrorUtils.debug("push: " + rest, new Error().getStackTrace(), true);
			return super.push.apply(this, rest);
		}

        override AS3 function pop():*
        {
            var poppedItem:* = super.pop();
			if(poppedItem is CursorBookmark)
				ErrorUtils.debug("pop: " + CursorBookmark(poppedItem).value, new Error().getStackTrace(), true);
            return poppedItem;
        }
	}
}