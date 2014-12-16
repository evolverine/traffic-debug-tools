package com.traffic.util.debugging
{
	import flash.text.TextField;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	public class StringUtils
	{
		public static function repeatString(str:String, times:int):String
		{
			var newString:String = "";
			while(--times >= 0)
			{
				newString += str;
			}
			
			return newString;
		}
	}
}
