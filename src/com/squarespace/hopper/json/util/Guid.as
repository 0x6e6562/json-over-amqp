package com.squarespace.hopper.json.util
{
	public class Guid
	{
		static var cnt:int = 0;
		
		public static function next():String {
			return ++cnt + "";
		}

	}
}