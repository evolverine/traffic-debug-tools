package com.traffic.util.debugging
{
    public class StringUtils
	{
		public static function endsWith(str:String, endsWith:String):Boolean
		{
			return str.indexOf(endsWith) == str.length - endsWith.length;
		}

		public static function startsWith(str:String, startsWith:String):Boolean
		{
			return str.indexOf(startsWith) == 0;
		}

		public static function trimSubstringLeft(str:String, substring:String):String
		{
			return startsWith(str, substring) ? str.substr(substring.length) : str;
		}

		public static function toAbbreviation(str:String):String
		{
            return str.replace(/[a-z_]/g, "");
		}
	}
}
