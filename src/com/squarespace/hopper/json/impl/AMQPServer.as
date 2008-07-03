/**
 * ---------------------------------------------------------------------------
 *   Copyright (C) 2008 0x6e6562
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 * ---------------------------------------------------------------------------
 **/
package com.squarespace.hopper.json.impl
{
	import com.adobe.serialization.json.JSON;
	import com.squarespace.hopper.json.RequestHandler;
	
	import flash.utils.ByteArray;
	
	import org.amqp.BasicConsumer;
	import org.amqp.Connection;
	import org.amqp.ProtocolEvent;
	import org.amqp.headers.BasicProperties;
	import org.amqp.methods.basic.Consume;
	import org.amqp.methods.basic.Deliver;
	import org.amqp.methods.queue.DeclareOk;
	import org.amqp.util.Properties;

	public class AMQPServer extends AMQPDelegate implements BasicConsumer
	{
		public var requestHandler:RequestHandler;
		public var bindingKey:String;
		
		private var consumerTag:String;
		
		public function AMQPServer(c:Connection)
		{
			trace(new Date() + " - Starting AMQP JSON Server.....please stand by");
			super(c);
		}
		
		override protected function onRequestOk(event:ProtocolEvent):void {			
			declareExchange(exchange,exchangeType);
			declareQueue("");
			sessionHandler.addEventListener(new DeclareOk(),onQueueDeclareOk);	
		}
		
		override protected function onQueueDeclareOk(event:ProtocolEvent):void {
			var declareOk:DeclareOk = event.command.method as DeclareOk;
			bindQueue(exchange,declareOk.queue,bindingKey);
			var consume:Consume = new Consume();
        	consume.queue = declareOk.queue;
        	consume.noack = true;
        	sessionHandler.register(consume, this);
		}
		
		
		public function onConsumeOk(tag:String):void {
        	consumerTag = tag;
        	trace(new Date() + " - AMQP JSON Server has booted and will now accept requests :-)");
        }
        
		public function onCancelOk(tag:String):void {}
		
		public function onDeliver(method:Deliver, 
								  inProps:BasicProperties,
								  body:ByteArray):void {
			var encoded:String = body.readUTF();
			var param:* = JSON.decode(encoded);
			var result:* = requestHandler.process(param);
			var response:String = JSON.encode(result);
			var data:ByteArray = new ByteArray();
			data.writeUTF(response);
			var outProps:BasicProperties = Properties.getBasicProperties();
			outProps.correlationid = inProps.correlationid;
			publish("",inProps.replyto,data,outProps);
			trace(new Date() + " - Received " + encoded + " as input, returning " + response);
		}
		
	}
}