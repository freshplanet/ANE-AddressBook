package com.freshplanet.ane.addressbook;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentResolver;
import android.database.Cursor;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.util.Log;

/**
 * The daemon is the part of the ane that queries the address book
 * it is run in a separate thread
 */
public class AddressBookDaemon implements Runnable { 
	
	private HashSet<String> contactCache ;
	private ContentResolver contentResolver ;
	private AddressBookDaemonCallback callback ;
	private int batchSize ;
	
	public AddressBookDaemon( HashSet<String> contactCache, int batchSize, ContentResolver contentResolver, AddressBookDaemonCallback callback ) {
		
		this.contactCache = contactCache ;
		this.contentResolver = contentResolver ;
		this.callback = callback ;
		this.batchSize = batchSize ;
	}
	
	@Override
	public void run() {
		try{// handle interruption
		
		callback.dispatchEvent(AddressBookEvent.JOB_STARTED, "");
			
		Boolean hasNewEntries = false ;
		
		JSONObject newEntries = new JSONObject() ;
		

		// parse phones
		Cursor contactCursor = this.contentResolver.query(
				Phone.CONTENT_URI, 
				new String[] { Phone.NUMBER, Phone.DISPLAY_NAME,  },
				null, null, null
			);
		
		// iterate over the cursor
		while( contactCursor.moveToNext() )
		{
			stopIfInterrupted() ;
			String phone = contactCursor.getString(0) ;
			String compositeName = contactCursor.getString(1);
			if ( phone == "null" || phone == null ) continue ;
			String phoneId = "phoneNumber_" + phone ;
			if( !contactCache.contains( phoneId ) )
			{
				hasNewEntries = true ;
				JSONObject nameObj = new JSONObject();
				try {
					nameObj.put("firstName", compositeName != null ? compositeName : "null");
					newEntries.put(phoneId, nameObj);
				} catch (JSONException e) {
					Log.e (AddressBook.TAG, e.getMessage());
					continue;
				}
				
				contactCache.add(phoneId) ;
				
				if ( batchSize > 0 && newEntries.length() >= batchSize )
				{
					sendJSON(newEntries,false) ;
					newEntries = new JSONObject();
				}
				
			}
		}
		contactCursor.close();
		
		// parse phones
		contactCursor = this.contentResolver.query(
				Email.CONTENT_URI,
				new String[] { Email.ADDRESS, Email.DISPLAY_NAME_PRIMARY  },
				null, null, null
			);
		
		// iterate over the cursor
		while( contactCursor.moveToNext() )
		{
			stopIfInterrupted() ;
			String email = contactCursor.getString(0) ;
			String compositeName = contactCursor.getString(1);
			if ( email == null || email == "null" ) continue ;
			String emailId = "email_" + email ;
			if( !contactCache.contains( emailId ) )
			{
				hasNewEntries = true ;
				JSONObject nameObj = new JSONObject();
				try {
					nameObj.put("firstName", (compositeName != null && compositeName != email) ? compositeName : "null");
					newEntries.put(emailId, nameObj);
				} catch (JSONException e) {
					Log.e(AddressBook.TAG, e.getMessage());
				}

				contactCache.add(emailId) ;
				
				if ( batchSize > 0 && newEntries.length() >= batchSize )
				{
					sendJSON(newEntries,false) ;
					newEntries = new JSONObject();
				}
				
			}
		}
		contactCursor.close();
		
		callback.updateCache( contactCache ) ;
		
		sendJSON(newEntries, hasNewEntries) ;
		
		
		} 
		catch(InterruptedException e) 
		{
			// do nothing, we just wanted the function to end
		} 
		finally 
		{
			callback.dispatchEvent(AddressBookEvent.JOB_FINISHED, "");
		}
		
	}
	
	private void sendJSON( JSONObject newEntries, Boolean parseEnd ) 
	{
		
		if( newEntries.length() > 0 )
		{
			try {
				newEntries.put("__parseEnd", parseEnd);
				callback.dispatchEvent(AddressBookEvent.CONTACTS_UPDATED, newEntries.toString()) ;
			} catch (JSONException e) {
				Log.e(AddressBook.TAG, e.getMessage());
			}
		}
		
	}
	
	private void stopIfInterrupted() throws InterruptedException {
		Thread.yield() ;
		if(Thread.currentThread().isInterrupted()) {
			throw new InterruptedException("stopped by parent Thread") ;
		}
	}

}
