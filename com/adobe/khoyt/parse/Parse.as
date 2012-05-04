package com.adobe.khoyt.parse
{
	import com.adobe.khoyt.parse.events.ParseEvent;
	import com.adobe.khoyt.parse.utils.Base64;
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class Parse extends EventDispatcher
	{
		public static const PARSE_API:String = "https://api.parse.com/1/classes/";
		public static const JSON_CONTENT:String = "application/json";
		
		private var hold:Object = null;
		private var applicationId:String = null;
		private var restApiKey:String = null;
		private var loader:URLLoader = null;
		
		public function Parse( applicationId:String, restApiKey:String )
		{
			super();
			this.applicationId = applicationId;
			this.restApiKey = restApiKey;
		}
		
		private function createURLRequest(className:String, requestMethod:String, data:Object = null):URLRequest
		{
			var request:URLRequest = new URLRequest(PARSE_API + className);
			request.method = requestMethod;
			request.contentType = JSON_CONTENT;
			request.data = data;
			request.requestHeaders.push(new URLRequestHeader("Content-Type","application/json"));
			request.requestHeaders.push( new URLRequestHeader("X-Parse-Application-Id", this.applicationId) );
			request.requestHeaders.push( new URLRequestHeader("X-Parse-REST-API-Key", this.restApiKey));
			
			return request;
		}
		
		public function count( className:String, where:String = null, count:Number = 1, limit:Number = 0 ):void
		{
			var query:URLVariables = null;
			var request:URLRequest = null;	
			
			query = new URLVariables();			
			query.count = count;
			query.limit = limit;			
			
			if( where != null )
			{
				query.where = JSON.encode( where );
			}
			
			
			request = createURLRequest(className, URLRequestMethod.GET, query);
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doCountComplete );
			loader.load( request );			
		}
		
		public function create( className:String, value:Object ):void
		{
			var request:URLRequest = null;	
			
			hold = value;
			
			request = createURLRequest(className, URLRequestMethod.POST, JSON.encode( value ));
			
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}

			loader.addEventListener( Event.COMPLETE, doCreateComplete );
			loader.load( request );			
		}
		
		public function read( className:String, objectId:String ):void
		{
			var request:URLRequest = createURLRequest(className + "/" + objectId, URLRequestMethod.GET, null);
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doReadComplete );
			loader.load( request );			
		}		
		
		public function remove( className:String, objectId:String ):void
		{
			var request:URLRequest = createURLRequest(className + "/" + objectId, URLRequestMethod.DELETE, null);;	
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doRemoveComplete );
			loader.load( request );			
		}				
		
		public function search( className:String, where:Object = null, limit:Number = 100, skip:Number = 0 ):void
		{
			var query:URLVariables = null;
			var request:URLRequest = null;	
			
			query = new URLVariables();
			query.limit = limit;
			query.skip = skip;
			
			if( where != null )
			{
				query.where = JSON.encode( where );
			}
			
			
			request = createURLRequest(className, URLRequestMethod.GET, query);
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doSearchComplete );
			loader.load( request );			
		}						
		
		public function update( className:String, objectId:String, value:Object ):void
		{
			var request:URLRequest = createURLRequest(className + "/" + objectId, URLRequestMethod.PUT, JSON.encode( value ));	
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doUpdateComplete );
			loader.load( request );			
		}				
		
		protected function doCountComplete( event:Event ):void
		{
			var dispatch:ParseEvent = null;
			var decode:Object = JSON.decode( loader.data );
			
			loader.removeEventListener( Event.COMPLETE, doCountComplete );
			
			dispatch = new ParseEvent( ParseEvent.COUNT );
			dispatch.value = decode.count;
			dispatchEvent( dispatch );			
		}
		
		protected function doCreateComplete( event:Event ):void
		{
			var dispatch:ParseEvent = null;
			var decode:Object = JSON.decode( loader.data );
			
			loader.removeEventListener( Event.COMPLETE, doCreateComplete );
			
			hold.createdAt = decode.createdAt;
			hold.objectId = decode.objectId;
			
			dispatch = new ParseEvent( ParseEvent.CREATE );
			dispatch.value = hold;
			dispatchEvent( dispatch );
		}
		
		protected function doReadComplete( event:Event ):void
		{
			var dispatch:ParseEvent = null;
			
			loader.removeEventListener( Event.COMPLETE, doReadComplete );
			
			dispatch = new ParseEvent( ParseEvent.READ );
			dispatch.value = JSON.decode( loader.data );
			dispatchEvent( dispatch );
		}
		
		protected function doRemoveComplete( event:Event ):void
		{
			loader.removeEventListener( Event.COMPLETE, doRemoveComplete );
			
			dispatchEvent( new ParseEvent( ParseEvent.REMOVE ) );
		}
		
		protected function doSearchComplete( event:Event ):void
		{
			var dispatch:ParseEvent = null;
			var decode:Object = JSON.decode( loader.data );
			
			loader.removeEventListener( Event.COMPLETE, doSearchComplete );
			
			dispatch = new ParseEvent( ParseEvent.SEARCH );
			dispatch.value = decode.results;
			dispatchEvent( dispatch );
		}
		
		protected function doUpdateComplete( event:Event ):void
		{
			var dispatch:ParseEvent = null;
			
			loader.removeEventListener( Event.COMPLETE, doUpdateComplete );
			
			dispatch = new ParseEvent( ParseEvent.UPDATE );
			dispatch.value = JSON.decode( loader.data );
			dispatchEvent( dispatch );
		}
	}
}