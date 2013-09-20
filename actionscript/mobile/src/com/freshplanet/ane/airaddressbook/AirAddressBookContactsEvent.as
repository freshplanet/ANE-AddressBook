package com.freshplanet.ane.airaddressbook {

import flash.events.Event ;

public class AirAddressBookContactsEvent extends flash.events.Event
{

	public var contactsData : Object ;

	public var isLastPacket : Boolean ;

	public function AirAddressBookContactsEvent( contactsData:Object, isLastPacket:Boolean = false )
	{

		super( AirAddressBook.CONTACTS_UPDATED ) ;

		this.contactsData=contactsData ;
		this.isLastPacket = isLastPacket ;

	}

}

}