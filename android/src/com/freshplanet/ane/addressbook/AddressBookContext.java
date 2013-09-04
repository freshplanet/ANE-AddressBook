package com.freshplanet.ane.addressbook;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.freshplanet.ane.addressbook.functions.AddressBookFunctionCheck;
import com.freshplanet.ane.addressbook.functions.AddressBookFunctionInit;

public class AddressBookContext extends FREContext implements AddressBookDaemonCallback {
	
	private HashSet<String> cache ;

	private Thread currentJob ;
	
	public AddressBookContext() {
		
		cache = new HashSet<String>() ;
		
	}
	
	@Override
	public void dispose() {
		if( this.currentJob != null && currentJob.isAlive() ) {
			this.currentJob.interrupt() ;
			try {
				// block current thread until job thread has acknowledged his interruption and returned
				this.currentJob.join() ;
			} catch (InterruptedException e) {}
		}
	}

	@Override
	public void updateCache(HashSet<String> cache) {
		this.cache = cache ;  
	}

	@Override
	public void dispatchEvent(String eventName, String value) {
		
		this.dispatchStatusEventAsync( eventName, value ) ;
		
	}
	
	// Functions
	public Boolean startJob( int batchSize ) {
		
		if( currentJob != null && currentJob.isAlive() ) {
			this.dispatchStatusEventAsync( AddressBookEvent.JOB_RUNNING, "" ) ;
			return false ;
		}
		
		this.currentJob = new Thread( new AddressBookDaemon( cache, batchSize, this.getActivity().getContentResolver(), this ) ) ;
		this.currentJob.start() ;
		
		return true ;
		
	}
	
	// Context Configuration
	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
		functions.put("init", new AddressBookFunctionInit());
        functions.put("check", new AddressBookFunctionCheck());
        return functions ;
	}

}