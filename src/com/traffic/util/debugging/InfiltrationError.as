package com.traffic.util.debugging
{
	public class InfiltrationError extends Error
	{
		public static const STACK_OVERFLOW_DANGER:String = "danger of stack overflow";
		public static const STACK_OVERFLOW_DANGER_EXPLANATION:String = "as you're probably overriding set mxmlContent, and the element to be replaced is in the root, calling this function will probably lead to stack overflow.";
		
		private var _newMXMLContent:Array = null;
		
		public function InfiltrationError(message:*="", id:*=0, newMXMLContent:Array=null)
		{
			super(STACK_OVERFLOW_DANGER_EXPLANATION, STACK_OVERFLOW_DANGER);
			_newMXMLContent = newMXMLContent;
		}

		public function get newMXMLContent():Array
		{
			return _newMXMLContent;
		}
	}
}