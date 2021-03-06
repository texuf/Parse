package
{
	import com.adobe.khoyt.parse.Parse;
	import com.adobe.khoyt.parse.events.ParseEvent;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class ParseTest extends Sprite
	{
		public static const DATA_SIZE:Number = 20;
		public static const GAME_SCORE:String = "GameScore";
		public static const MAX_SCORE:Number = 5000;
		
		private var count:Number = 0;
		private var parse:Parse = null;
		private var id:String = null;
		
		private var tf:TextField;
		
		public function ParseTest()
		{
			super();
			init();
		}
		
		private function init():void
		{
			parse = new Parse( Constants.APPLICATION_ID, Constants.REST_API_KEY );
			parse.addEventListener( ParseEvent.COUNT, doParseCount );
			parse.addEventListener( ParseEvent.CREATE, doParseCreate );
			parse.addEventListener( ParseEvent.READ, doParseRead );
			parse.addEventListener( ParseEvent.UPDATE, doParseUpdate );
			parse.addEventListener( ParseEvent.REMOVE, doParseRemove );	
			parse.addEventListener( ParseEvent.SEARCH, doParseSearch );
			parse.count( GAME_SCORE );
			
			tf = new TextField();
			
			addChild(tf);
			
			tf.border = true;
			tf.width = 320 - 50*2;
			tf.height = 460 - 50*2;
			tf.x = 50;
			tf.y = 50;
		}
		
		protected function doParseCount( event:ParseEvent ):void
		{
			var data:Object = null;
			
			count = new Number( event.value );
			
			trace( "Found " + count + " records." );	
			tf.appendText( "Found " + count + " records. \n"); 
			
			data = {
				score: Math.round( Math.random() * MAX_SCORE ),
					playerName: "Sean Plott",
					cheatMode: Math.random() > 0.50 ? false : true				
			};										
			
			parse.create( GAME_SCORE, data );				
		}
		
		protected function doParseCreate( event:ParseEvent ):void
		{
			var data:Object = null;
			
			trace( "Created: " + event.value.objectId );
			tf.appendText("Created: " + event.value.objectId + "\n");
			
			
			if( count < ( DATA_SIZE - 1 ) )
			{				
				count = count + 1;
				
				data = {
					score: Math.round( Math.random() * MAX_SCORE ),
						playerName: "Sean Plott",
						cheatMode: Math.random() > 0.50 ? true : false				
				};				
				
				parse.create( GAME_SCORE, data );
			} else {
				id = event.value.objectId;
				parse.read( GAME_SCORE, event.value.objectId );
			}
		}
		
		protected function doParseRead( event:ParseEvent ):void
		{
			var change:Object = null;
			
			trace( "Read full record: " + event.value.playerName );
			tf.appendText( "Read full record: " + event.value.playerName + "\n");
			
			change = {
				playerName: "Kevin Hoyt"
			};
			parse.update( GAME_SCORE, event.value.objectId, change );
		}
		
		protected function doParseRemove( event:ParseEvent ):void
		{
			trace( "Object " + id + " removed." );
			tf.appendText( "Object " + id + " removed." + "\n");
			parse.search( GAME_SCORE, {playerName: "Kevin Hoyt"} );
		}		
		
		protected function doParseSearch( event:ParseEvent ):void
		{
			if( id != null )
			{
				trace( "Found " + event.value.length + " matching records." );				
				tf.appendText("Found " + event.value.length + " matching records." + "\n");
				id = null;
				parse.search( GAME_SCORE, {playerName: "Sean Plott"}, 200, 100 );
			} else {
				trace( "Got " + event.value.length + " matching records." );				
			}
		}
		
		protected function doParseUpdate( event:ParseEvent ):void
		{
			trace( "Updated at: " + event.value.updatedAt );
			tf.appendText( "Updated at: " + event.value.updatedAt + "\n");
			parse.remove( GAME_SCORE, id );
		}
	}
}