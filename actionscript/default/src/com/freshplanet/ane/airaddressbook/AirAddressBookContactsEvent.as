package com.freshplanet.ane.airaddressbook {

import flash.events.Event ;

public class AirAddressBookContactsEvent extends flash.events.Event
{

	public var contactsData : String ;

	public function AirAddressBookContactsEvent( contactsData:String )
	{

		super( AirAddressBook.CONTACTS_UPDATED ) ;

		this.contactsData=contactsData ;

	}

}

}