package com.freshplanet.ane.addressbook;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class AddressBook implements FREExtension{
	
	private AddressBookContext context ;
	
	public FREContext createContext(String arg0){
		if( context == null )
			context = new AddressBookContext() ; 
		return context ;
	}
	
	@Override
	public void dispose() {
		// nothing to do here
	}

	@Override
	public void initialize() {
		// nothing to do here either
	}
	
}