package
{
	import com.distriqt.extension.location.AuthorisationStatus;
	import com.distriqt.extension.location.Location;
	import com.distriqt.extension.location.events.AuthorisationEvent;
	import com.distriqt.extension.location.events.RegionEvent;
	import com.distriqt.extension.location.geofences.Region;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Main extends Sprite
	{
		private var _logTextField:TextField;


		public function Main()
		{
			_logTextField = new TextField();
			_logTextField.defaultTextFormat = new TextFormat( "_typewriter", 18 );
			addChild( _logTextField );

			log( "startup" );

			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
		}


		private function log( message:String ):void
		{
			trace( message );
			_logTextField.appendText( message + "\n" );
		}


		private function addedToStageHandler( event:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			_logTextField.width = stage.stageWidth;
			_logTextField.height = stage.stageHeight;

			if (Location.isSupported)
			{
				//  Functionality here
				Location.service.addEventListener( AuthorisationEvent.CHANGED, authorisationChangedHandler );
				checkAuthorisation();
			}
		}


		private function checkAuthorisation():void
		{
			switch (Location.service.authorisationStatus())
			{
				case AuthorisationStatus.ALWAYS:
				case AuthorisationStatus.IN_USE:
					log( "User allowed access: " + Location.service.authorisationStatus() );
					startMonitoringRegion();
					break;

				case AuthorisationStatus.NOT_DETERMINED:
				case AuthorisationStatus.SHOULD_EXPLAIN:
					log( "Requesting authorisation" );
					Location.service.requestAuthorisation( AuthorisationStatus.ALWAYS );
					break;

				case AuthorisationStatus.RESTRICTED:
				case AuthorisationStatus.DENIED:
				case AuthorisationStatus.UNKNOWN:
					log( "User denied access" );
					break;
			}
		}


		private function authorisationChangedHandler( event:AuthorisationEvent ):void
		{
			checkAuthorisation();
		}


		private function startMonitoringRegion():void
		{
			if (!Location.service.isAvailable())
			{
				Location.service.displayLocationSettings();
				return;
			}

			Location.service.geofences.addEventListener( RegionEvent.START_MONITORING, startMonitoringHandler );
			Location.service.geofences.addEventListener( RegionEvent.ENTER, enterHandler );
			Location.service.geofences.addEventListener( RegionEvent.EXIT, exitHandler );

			var region:Region = new Region();
			region.identifier = "some-unique-id";
			region.latitude = -27.47;
			region.longitude = 153.03;
			region.radius = 100;
			region.startApplicationOnEnter = true;

			var success:Boolean = Location.service.geofences.startMonitoringRegion( region );
			log( "startMonitoringRegion(): " + success );
		}


		private function startMonitoringHandler( event:RegionEvent ):void
		{
			log( "startMonitoringHandler" );
		}

		private function enterHandler( event:RegionEvent ):void
		{
			log( "enterHandler" );
		}

		private function exitHandler( event:RegionEvent ):void
		{
			log( "exitHandler" );
		}


	}
}
