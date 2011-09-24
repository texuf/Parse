package com.adobe.khoyt.parse
{
	import com.adobe.serialization.json.JSON;
	
	import com.adobe.khoyt.parse.events.ParseEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import com.adobe.khoyt.parse.utils.Base64;

	public class Parse extends EventDispatcher
	{
		public static const PARSE_API:String = "https://api.parse.com/1/classes/";
		public static const JSON_CONTENT:String = "application/json";
		
		private var hold:Object = null;
		private var username:String = null;
		private var password:String = null;
		private var loader:URLLoader = null;
		
		public function Parse( username:String, password:String )
		{
			super();
			this.username = username;
			this.password = password;
		}
		
		public function create( className:String, value:Object ):void
		{
			var authorization:String = null;			
			var request:URLRequest = null;	
			var header:URLRequestHeader = null;			
			
			hold = value;
			
			authorization = Base64.encode( username + ":" + password );			
			header = new URLRequestHeader( "Authorization", "Basic " + authorization );						
			
			request = new URLRequest( PARSE_API + className );
			request.method = URLRequestMethod.POST;
			request.contentType = JSON_CONTENT;
			request.data = JSON.encode( value );
			request.requestHeaders.push( header );
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}

			loader.addEventListener( Event.COMPLETE, doCreateComplete );
			loader.load( request );			
		}
		
		public function read( className:String, objectId:String ):void
		{
			var authorization:String = null;			
			var request:URLRequest = null;	
			var header:URLRequestHeader = null;			
			
			authorization = Base64.encode( username + ":" + password );			
			header = new URLRequestHeader( "Authorization", "Basic " + authorization );						
			
			request = new URLRequest( PARSE_API + className + "/" + objectId );
			request.method = URLRequestMethod.GET;
			request.contentType = JSON_CONTENT;
			request.requestHeaders.push( header );
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doReadComplete );
			loader.load( request );			
		}		
		
		public function remove( className:String, objectId:String ):void
		{
			var authorization:String = null;			
			var request:URLRequest = null;	
			var header:URLRequestHeader = null;			
			
			authorization = Base64.encode( username + ":" + password );			
			header = new URLRequestHeader( "Authorization", "Basic " + authorization );						
			
			request = new URLRequest( PARSE_API + className + "/" + objectId );
			request.method = URLRequestMethod.DELETE;
			request.contentType = JSON_CONTENT;
			request.requestHeaders.push( header );
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doRemoveComplete );
			loader.load( request );			
		}				
		
		public function search( className:String, where:Object = null ):void
		{
			var authorization:String = null;
			var query:URLVariables = null;
			var request:URLRequest = null;	
			var header:URLRequestHeader = null;			
			
			if( where != null )
			{
				query = new URLVariables();
				query.where = JSON.encode( where );
			}
			
			authorization = Base64.encode( username + ":" + password );			
			header = new URLRequestHeader( "Authorization", "Basic " + authorization );						
			
			request = new URLRequest( PARSE_API + className );
			request.method = URLRequestMethod.GET;
			request.contentType = JSON_CONTENT;
			
			if( where != null )
			{
				request.data = query;				
			}

			request.requestHeaders.push( header );
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doSearchComplete );
			loader.load( request );			
		}						
		
		public function update( className:String, objectId:String, value:Object ):void
		{
			var authorization:String = null;			
			var request:URLRequest = null;	
			var header:URLRequestHeader = null;			
			
			authorization = Base64.encode( username + ":" + password );			
			header = new URLRequestHeader( "Authorization", "Basic " + authorization );						
			
			request = new URLRequest( PARSE_API + className + "/" + objectId );
			request.method = URLRequestMethod.PUT;
			request.contentType = JSON_CONTENT;
			request.data = JSON.encode( value );
			request.requestHeaders.push( header );
			
			if( loader == null )
			{
				loader = new URLLoader();				
			}
			
			loader.addEventListener( Event.COMPLETE, doUpdateComplete );
			loader.load( request );			
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
			
			hold = null;
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