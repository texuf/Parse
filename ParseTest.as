package
{
	import com.adobe.khoyt.parse.Parse;
	import com.adobe.khoyt.parse.events.ParseEvent;
	
	import flash.display.Sprite;
	
	public class ParseTest extends Sprite
	{
		public static const GAME_SCORE:String = "GameScore";
		
		private var parse:Parse = null;
		private var id:String = null;
		
		public function ParseTest()
		{
			super();
			init();
		}
		
		private function init():void
		{
			var data:Object = null;
			
			data = {
				score: 1337,
				playerName: "Sean Plott",
				cheatMode: false				
			};

			parse = new Parse( Constants.USERNAME, Constants.PASSWORD );
			parse.addEventListener( ParseEvent.CREATE, doParseCreate );
			parse.addEventListener( ParseEvent.READ, doParseRead );
			parse.addEventListener( ParseEvent.UPDATE, doParseUpdate );
			parse.addEventListener( ParseEvent.REMOVE, doParseRemove );	
			parse.addEventListener( ParseEvent.SEARCH, doParseSearch );
			parse.create( GAME_SCORE, data );
		}
		
		protected function doParseCreate( event:ParseEvent ):void
		{
			trace( "Created: " + event.value.objectId );
			
			id = event.value.objectId;
			parse.read( GAME_SCORE, event.value.objectId );
		}
		
		protected function doParseRead( event:ParseEvent ):void
		{
			var change:Object = null;
			
			trace( "Read full record: " + event.value.playerName );
			
			change = {
				playerName: "Kevin Hoyt"
			};
			parse.update( GAME_SCORE, event.value.objectId, change );
		}
		
		protected function doParseRemove( event:ParseEvent ):void
		{
			trace( "Object " + id + " removed." );
			id = null;
			
			parse.search( GAME_SCORE, {playerName: "Kevin Hoyt"} );
		}		
		
		protected function doParseSearch( event:ParseEvent ):void
		{
			trace( "Found " + event.value.length + " records." );
		}
		
		protected function doParseUpdate( event:ParseEvent ):void
		{
			trace( "Updated at: " + event.value.updatedAt );
			parse.remove( GAME_SCORE, id );
		}
	}
}