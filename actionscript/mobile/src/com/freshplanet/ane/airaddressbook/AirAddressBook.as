package com.freshplanet.ane.airaddressbook
{
	import flash.events.EventDispatcher;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class AirAddressBook extends EventDispatcher
	{
		
		
		public static const CONTACTS_UPDATED:String = "contacts_updated" ;
		public static const JOB_RUNNING:String = "job_running" ;
		public static const ACCESS_DENIED:String = "access_denied" ;
		public static const ACCESS_GRANTED:String = "access_granted" ;
		
		public static const PERMISSION_GRANTED:int = 1 ;
		public static const PERMISSION_DENIED:int = 0 ;
		public static const PERMISSION_UNKNOWN:int = -1 ;

		private static const EXTENSION_ID : String = "com.freshplanet.ane.AirAddressBook";
		
		private static var _instance : AirAddressBook;
		
		private var _context : ExtensionContext;

		public static function get isSupported() : Boolean
		{
			return 	Capabilities.manufacturer.indexOf("iOS") != -1 || 
					Capabilities.manufacturer.indexOf("Android") != -1 ;
		}
		
		public function AirAddressBook()
		{
			if (!_instance)
			{
				createContextIfNull() ;
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}
		
		public static function getInstance():AirAddressBook
		{
			return _instance ? _instance : new AirAddressBook();
		}

		public function initCache( cache:Array ):void {
			createContextIfNull() ;
			_context.call("init", cache) ;
		}
		
		/**
		 * @returns	true on Android,
		 *			true if the user has given system permission to use addressbook and flase otherwise on iOS
		 */
		public function hasPermission():int
		{

			if( Capabilities.manufacturer.indexOf("iOS") >=1 )
			{
				createContextIfNull() ;
				return _context.call("hasPermission") as int ;
			}

			return PERMISSION_GRANTED ;

		}

		public function check( batchSize:int ) : void {
			createContextIfNull() ;
			_context.call("check", batchSize) ;
		}

		private function createContextIfNull():void {
			if( !_context )
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID,null);
				if (!_context)
				{
					throw Error("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);
			}
		}

		private function onStatus( event:StatusEvent ) : void
		{

			trace("[AirAddressBook] onStatus: ", event.code, event.level);

			if( event.code == JOB_RUNNING ||
				event.code == ACCESS_DENIED
			) {
				this.dispatchEvent( new ErrorEvent(event.code) ) ;
			} else if ( event.code == ACCESS_GRANTED ){
				this.dispatchEvent( new Event( event.code ) ) ;
			} else if ( event.code == CONTACTS_UPDATED ) {
				
				var raw:String = event.level ;

				try {
					var dat:Object = JSON.parse( raw ) ;
					var isLast:Boolean = dat.hasOwnProperty('__parseEnd') && dat['__parseEnd'] == "true" ;
					delete dat['__parseEnd'] ;
					this.dispatchEvent( new AirAddressBookContactsEvent( dat, isLast ) ) ;
				} catch (e:Error) {
					trace("[Peter][AirAddressBook] " + e.message + "\n" + raw);
				}
				
			}
			
		}
	}
}