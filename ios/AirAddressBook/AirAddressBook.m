//
//  AirAddressBook.m
//  AirAddressBook
//
//  Created by Renaud Bardet on 09/08/13.
//  Copyright (c) 2013 Freshplanet. All rights reserved.
//

#import "AirAddressBook.h"

FREContext AirCtx = nil;

NSString *const CONTACTS_UPDATED = @"contacts_updated" ;

NSString *const JOB_RUNNING = @"job_running" ;
NSString *const ACCESS_DENIED = @"access_denied" ;
NSString *const ACCESS_GRANTED = @"access_granted" ;

@implementation AirAddressBook

@synthesize cache = _cache;

static AirAddressBook *sharedInstance = nil;
+ (AirAddressBook *) sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (void)log:(NSString *)format, ...
{
    @try
    {
        va_list args;
        va_start(args, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
        ALog(@"[AirAddressBook] %@", string);
        [AirAddressBook dispatchFREEvent:@"LOGGING"withLevel:string];
    }
    @catch (NSException *exception)
    {
        ALog(@"[AirAddressBook] Couldn't log message. Exception: %@", exception);
    }
}

+ (void)dispatchFREEvent:(NSString *)code withLevel:(NSString *)level
{
    FREDispatchStatusEventAsync(AirCtx, (const uint8_t *)[code UTF8String], (const uint8_t *)[level UTF8String]);
}


- (void) initWithCache:(NSMutableSet*)cache
{
    self.cache = cache ;
}

- (int) hasPermission
{
    
    if ([self isIOS6]) {
        return 1 ;
    }
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus() ;
    
    if ( status == kABAuthorizationStatusAuthorized ) {
        return 1 ;
    }
    if ( status == kABAuthorizationStatusNotDetermined ) {
        return -1 ;
    }
    
    return 0 ;
    
}

- (void) doCheck:(NSNumber *) batchSize
{
    
    // get addressBook pointer
    ABAddressBookRef addressBookRef = NULL;
    
    if ([self isIOS6])
    {
        addressBookRef = ABAddressBookCreateWithOptions(nil,nil);
        ABAuthorizationStatus curStatus = ABAddressBookGetAuthorizationStatus();
        if (curStatus == kABAuthorizationStatusNotDetermined)
        {
            ABAddressBookRequestAccessWithCompletion(addressBookRef,^(bool granted, CFErrorRef error) {
                if ( granted ) [AirAddressBook dispatchFREEvent:ACCESS_GRANTED withLevel:@""];
                [self onAuthorization:addressBookRef granted:granted batchSize:batchSize];
                CFRelease(addressBookRef);
            });
        }
        else
        {
            [self onAuthorization:addressBookRef granted:[self isStatusAvailable:curStatus] batchSize:batchSize];
            if( addressBookRef != NULL ) CFRelease(addressBookRef);
        }
    }
    else
    {
        addressBookRef = ABAddressBookCreate();
        [self onAuthorization:addressBookRef granted:true batchSize:batchSize];
        CFRelease(addressBookRef);
    }
    
}

- ( BOOL ) isIOS6
{
    float currentVersion = 6.0;
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion;
}

- (BOOL) isStatusAvailable:(ABAuthorizationStatus)theStatus
{
    return (theStatus == kABAuthorizationStatusAuthorized);
}

- (void) onAuthorization:(ABAddressBookRef)addressBookRef granted:(bool)granted batchSize:(NSNumber*) batchSize
{
    if (granted)
    {

        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        
        long currentLength = CFArrayGetCount(people) ;
        
        NSMutableArray *newContacts = [[NSMutableArray alloc] init] ;
        
        ABRecordRef contact ;
        for( int i=0; i<currentLength; ++i ) {

            contact = CFArrayGetValueAtIndex(people, i) ;
            
            CFStringRef compositeName = ABRecordCopyCompositeName(contact);
            CFStringRef firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty);
            CFStringRef lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty);
            CFArrayRef emails = ABMultiValueCopyArrayOfAllValues( ABRecordCopyValue(contact, kABPersonEmailProperty) );
            CFArrayRef phones = ABMultiValueCopyArrayOfAllValues( ABRecordCopyValue(contact, kABPersonPhoneProperty) );
            
            if(CFStringCompare(firstName, CFSTR("null"), kCFCompareCaseInsensitive) == kCFCompareEqualTo || CFStringCompare(firstName, CFSTR("(null)"), kCFCompareCaseInsensitive) == kCFCompareEqualTo )
                firstName = CFSTR("") ;
            
            if(CFStringCompare(lastName, CFSTR("null"), kCFCompareCaseInsensitive) == kCFCompareEqualTo || CFStringCompare(lastName, CFSTR("(null)"), kCFCompareCaseInsensitive) == kCFCompareEqualTo )
                lastName = CFSTR("") ;
            
            if(CFStringCompare(compositeName, CFSTR("null"), kCFCompareCaseInsensitive) == kCFCompareEqualTo || CFStringCompare(compositeName, CFSTR("(null)"), kCFCompareCaseInsensitive) == kCFCompareEqualTo )
                compositeName = CFSTR("") ;
            
            // does int exist in cache ?
            if( phones!=NULL )
            {
                CFIndex phonesCount = CFArrayGetCount(phones);
                for( int i=0; i<phonesCount; ++i )
                {
                    NSString *phone = CFArrayGetValueAtIndex(phones, i) ;
                    NSString *phoneId = [NSString stringWithFormat:@"phoneNumber_%@", phone] ;
                    if ( ![self.cache containsObject:phoneId] ) {
                        NSString *serialized = [NSString stringWithFormat:@"\"%@\":{\"compositeName\":\"%@\",\"firstName\":\"%@\",\"lastName\":\"%@\"}", phoneId, compositeName, firstName, lastName] ;
                        
                        [self.cache addObject:phoneId] ;
                        [newContacts addObject:serialized] ;
                        
                        if ( [batchSize intValue] > 0 && [newContacts count] > [batchSize intValue] ) {
                            [self dispatchContactUpdateEventwithContacts:newContacts] ;
                            [newContacts removeAllObjects] ;
                        }
                        
                    }
                }
            }
            
            if( emails!=NULL )
            {
                CFIndex emailsCount = CFArrayGetCount(emails);
                for( int i=0; i<emailsCount; ++i )
                {
                    NSString *email = CFArrayGetValueAtIndex(emails, i) ;
                    NSString *emailId = [NSString stringWithFormat:@"email_%@", email] ;
                    if ( ![self.cache containsObject:emailId] ) {
                        NSString *serialized = [NSString stringWithFormat:@"\"%@\":{\"compositeName\":\"%@\",\"firstName\":\"%@\",\"lastName\":\"%@\"}", emailId, compositeName, firstName, lastName] ;
                        
                        [self.cache addObject:emailId] ;
                        [newContacts addObject:serialized] ;
                        
                        if ( [batchSize intValue] > 0 && [newContacts count] > [batchSize intValue] ) {
                            [self dispatchContactUpdateEventwithContacts:newContacts] ;
                            [newContacts removeAllObjects] ;
                        }
                    }
                }
            }
            
            if( phones ) CFRelease(phones) ;
            if( emails ) CFRelease(emails) ;
            
        }
        
        [self dispatchContactUpdateEventwithContacts:newContacts] ;
        
        CFRelease(people);
        
    }
    else {
        [AirAddressBook dispatchFREEvent:ACCESS_DENIED withLevel:@""];
    }
    
    
}

- (void) dispatchContactUpdateEventwithContacts:(NSArray*) newContacts
{
    int newContactsCount = [newContacts count] ;
    if (newContactsCount > 0) {
        NSMutableString *data = [NSMutableString stringWithString:@"{"] ;
        for ( int i =0 ; i < newContactsCount ; ++i ) {
            [data appendString:newContacts[i]] ;
            if (i<newContactsCount-1) {
                [data appendString:@","] ;
            }
        }
        [data appendString:@"}"] ;
        [AirAddressBook dispatchFREEvent:CONTACTS_UPDATED withLevel:data] ;
    }
}

@end

// API
DEFINE_ANE_FUNCTION(ane_fct_init)
{
    
    FREObject input = argv[0] ;
    uint32_t inputLength = 0 ;
    if( FREGetArrayLength(input, &inputLength) == FRE_OK )
    {
        NSMutableSet *cache = [[NSMutableSet alloc] initWithCapacity:inputLength] ;
        for (uint i = 0; i < inputLength; ++i) {
            FREObject temp ;
            if( FREGetArrayElementAt(input, i, &temp) == FRE_OK )
            {
                const uint8_t *chars ;
                uint32_t charLength ;// not used
                if ( FREGetObjectAsUTF8(temp,&charLength,&chars) == FRE_OK ) {
                    NSString *entry = [NSString stringWithUTF8String:(char*)chars] ;
                    [cache addObject:entry] ;
                }
            }
        }
        
        [[AirAddressBook sharedInstance] initWithCache:cache];
    }
    
    return NULL ;
    
}

DEFINE_ANE_FUNCTION(ane_fct_has_perm)
{
    
    FREObject ret = NULL ;
    int permission = [[AirAddressBook sharedInstance] hasPermission] ;
    FRENewObjectFromInt32(permission, &ret) ;
    return ret ;
    
}

DEFINE_ANE_FUNCTION(ane_fct_check)
{
    
    int temp = -1;
    FREGetObjectAsInt32(argv[0], &temp) ;
    NSNumber *batchSize = [NSNumber numberWithInt:temp];
    [AirAddressBook log:@"%d, %@", temp, batchSize] ;
    
    
    [[AirAddressBook sharedInstance] performSelectorInBackground:@selector(doCheck:) withObject:batchSize];
    return NULL ;
    
}

// ANE SETUP

void AirAddressBookContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFunctionsToLink = 3 ;
    *numFunctionsToTest = nbFunctionsToLink;
    
	FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFunctionsToLink);
    
    func[0].name = (const uint8_t*)"init";
	func[0].functionData = NULL;
	func[0].function = &ane_fct_init;
    
    func[1].name = (const uint8_t*)"hasPermission";
	func[1].functionData = NULL;
	func[1].function = &ane_fct_has_perm;
    
    func[2].name = (const uint8_t*)"check";
	func[2].functionData = NULL;
	func[2].function = &ane_fct_check;
    
	*functionsToSet = func;
    
    AirCtx = ctx ;
}

void AirAddressBookContextFinalizer(FREContext ctx) { }

void AirAddressBookInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
  	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirAddressBookContextInitializer;
	*ctxFinalizerToSet = &AirAddressBookContextFinalizer;
}

void AirAddressBookFinalizer(void* extData) {}
