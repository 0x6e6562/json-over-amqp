package com.squarespace.hopper.json.util
{
	import flash.utils.ByteArray;
	
	[Embed(source="/serverContext.xml", mimeType="application/octet-stream")]
	public class ServerContext extends ByteArray
	{
	    public function getXML():XML
	    {
	         var xml:XML = new XML(readUTFBytes(length));
	         return xml;
	    }
	}
}