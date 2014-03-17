package com.freshplanet.ane.airaddressbook
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class AirAddressBook extends EventDispatcher
	{
		
		public static const CONTACTS_UPDATED:String = "contacts_updated" ;
		public static const JOB_STARTED:String = "job_started" ;
		public static const JOB_RUNNING:String = "job_running" ;
		public static const JOB_FINISHED:String = "job_finished" ;
		public static const ACCESS_DENIED:String = "access_denied" ;
		public static const ACCESS_GRANTED:String = "access_granted" ;

		public static const PERMISSION_GRANTED:int = 1 ;
		public static const PERMISSION_DENIED:int = 0 ;
		public static const PERMISSION_UNKNOWN:int = -1 ;
		
		public static function get isSupported() : Boolean
		{
			return false ;
		}
		
		public function AirAddressBook()
		{
		}
		
		/**
		 * initializes the cache with known identifiers
		 * @param cache 	an Array of String identifiers such as
		 *					phone_+11234567890
		 *					email_name@site.tld
		 */
		public function initCache( cache:Array ):void
		{
		}

		/**
		 * @returns	true on Android,
		 *			true if the user has given system permission to use addressbook and flase otherwise on iOS
		 */
		public function hasPermission():int
		{
			return -1 ;
		}

		public function check( batchSize:int ):void
		{
		}

		public static function getInstance():AirAddressBook
		{
			return new AirAddressBook();
		}

	}
		
}