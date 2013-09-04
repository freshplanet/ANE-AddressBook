package com.freshplanet.ane.addressbook.functions;

import java.util.HashSet;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.freshplanet.ane.addressbook.AddressBookContext;

public class AddressBookFunctionInit implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		try {
			
			FREArray input = (FREArray) arg1[0] ;
			
			HashSet<String> cache = new HashSet<String>() ;
			
			long inputLength = input.getLength() ;
			for ( int i = 0 ; i < inputLength ; ++i )
			{
				cache.add( input.getObjectAt(i).getAsString() ) ;
			}
			
			((AddressBookContext) arg0).updateCache( cache ) ;
			
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