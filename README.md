Air Native Extension for Facebook (iOS + Android)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for accessing the Address Book on iOS and Android. It has been developed by [FreshPlanet](http://freshplanet.com).


Installation
---------

The ANE binary (AirAddressBook.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).

Usage
---------
This ANE has a very specific working, it has been made to retrieve the contacts data in the background to get large address books without freezing the main thread,
so it is event driven

first you need to listen for AirAddressBookContactsEvent like this
AirAddressBook.getInstance().addEventListener(
   AirAddressBook.CONTACTS_UPDATED,
   myReceiverFunction
);

Then call the check method, it takes as parameter the number of contacts you want to retrieve per event,
if this number is low you are going to get more events with a smaller data each time, if it's high you are going to have less events with a bigger set each time,
I recommend that you keep it around 10
AirAddressBook.getInstance().check( 10 );

You are going to receive a few events depending on the size of your user's address book,
the property contactsData is a key value pair of the id of the contact in the phone and a JSON encoded set of properties like firstName lastName phone etc...
you need to recreate the complete dictionary by hand from there
You can test isLastPacket to see if the parsing has ended or if there is more coming,
alternatively you can listen for JOB_FINISHED on AirAddressBook.getInstance() to have it in a separate event

the process is incremental, so the next time you call check you will only receive new contacts since the last check
if you are saving the retrieved contacts somewhere else like in a database when exiting/relaunching, you can tell the ANE to
disregard the ids you already have by passing an Array of ids
AirAddressBook.getInstance().initCache( [id1,id2,...] )

This ANE has been designed for a particular app and may not suit all your needs, if it's the case here is the ANE we were using beforehand
https://github.com/memeller/ContactEditor

Build script
---------

Should you need to edit the extension source code and/or recompile it, you will find an ant build script (build.xml) in the *build* folder:

    cd /path/to/the/ane/build
    mv example.build.config build.config
    #edit the build.config file to provide your machine-specific paths
    ant


Authors
------

This ANE has been written by [Renaud Bardet](https://github.com/renaudbardet). It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
