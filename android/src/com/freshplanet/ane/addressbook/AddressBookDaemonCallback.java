package com.freshplanet.ane.addressbook;

import java.util.HashSet;

public interface AddressBookDaemonCallback {
	
	public void updateCache( HashSet<String> cache ) ;
	
	public void dispatchEvent( String eventName, String value ) ;
	
}
