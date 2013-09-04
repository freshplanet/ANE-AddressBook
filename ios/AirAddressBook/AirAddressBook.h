//
//  AirAddressBook.h
//  AirAddressBook
//
//  Created by Renaud Bardet on 09/08/13.
//  Copyright (c) 2013 Freshplanet. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import <AddressBook/AddressBook.h>

@interface AirAddressBook : NSObject

@property (nonatomic, strong) NSMutableSet *cache;

+ (AirAddressBook*) sharedInstance;

- (void) initWithCache:(NSMutableSet*)cache ;
- (int) hasPermission;
- (void) doCheck:(NSNumber*)batchSize;

+ (void) dispatchFREEvent:(NSString *)code withLevel:(NSString *)level;
+ (void) log:(NSString *)format, ...;

@end

// Main Functions
DEFINE_ANE_FUNCTION(ane_fct_init);
DEFINE_ANE_FUNCTION(ane_fct_has_perm);
DEFINE_ANE_FUNCTION(ane_fct_check);

// ANE Setup
void ContactEditorContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void ContactEditorContextFinalizer(FREContext ctx);
void ContactEditorExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void ContactEditorExtFinalizer(void* extData);