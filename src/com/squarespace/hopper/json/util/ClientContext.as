package com.squarespace.hopper.json.util
{
	import flash.utils.ByteArray;
	
	[Embed(source="/clientContext.xml", mimeType="application/octet-stream")]
	public class ClientContext extends ByteArray
	{
	    public function getXML():XML
	    {
	         var xml:XML = new XML(readUTFBytes(length));
	         return xml;
	    }
	}
}