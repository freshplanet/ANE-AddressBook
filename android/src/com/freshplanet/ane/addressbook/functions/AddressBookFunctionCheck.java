package com.freshplanet.ane.addressbook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.freshplanet.ane.addressbook.AddressBookContext;

public class AddressBookFunctionCheck implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		try {
			
			int batchSize = arg1[0].getAsInt() ;
			
			return FREObject.newObject( ((AddressBookContext) arg0).startJob( batchSize ) ) ;
			
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (IllegalStateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return null ;
		
	}

}