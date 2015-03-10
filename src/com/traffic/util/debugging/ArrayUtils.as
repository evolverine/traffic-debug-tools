/**
 * Distributed under Apache License v2.0. For more information
 * see LICENSE.
 */

package com.traffic.util.debugging
{
	import com.adobe.cairngorm.contract.Contract;

	public class ArrayUtils
	{
		/**
		 * Returns an array with all the items that the two arrays share
		 * from the beginning. I.e. if a = [1, 2, 3] and b = [1, 2, 4],
		 * the result is [1, 2]. But if they are [1, 2, 3] and [2, 3, 4],
		 * the result is [].
		 */
		public static function intersectionFromBeginning(a:Array, b:Array):Array
		{
			Contract.precondition(a != null && b != null);
			
			for (var i:int = 0; i < a.length; i++)
			{
				if(b.length <= i)
					break;
				
				if(a[i] !== b[i])
					break;
			}
			
			return a.slice(0, i);
		}
	}
}
