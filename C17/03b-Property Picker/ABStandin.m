//
//  AddressBook.m
//  HelloWorld
//
//  Created by Erica Sadun on 8/24/11.
//  Copyright (c) 2011 Up To No Good, Inc. All rights reserved.
//

#import "ABStandin.h"

static ABAddressBookRef shared = NULL;

@implementation ABStandin
// Return the current shared address book, 
// Creating if needed
+ (ABAddressBookRef) addressBook
{
    if (shared) return shared;
    
    shared = ABAddressBookCreate();
    return shared;
}

// Load the current address book
+ (ABAddressBookRef) currentAddressBook
{
    if (shared)
    {
        CFRelease(shared);
        shared = nil;
    }
    
    return [self addressBook];
}

// Thanks Frederic Bronner
// Save the address book out
+ (BOOL) save: (NSError **) error
{
    CFErrorRef cfError;
    if (shared)
    {
        BOOL success = ABAddressBookSave(shared, &cfError);
        if (!success)
        {
            if (error)
                *error = (__bridge_transfer NSError *)cfError;
            return NO;
        }        
        return YES;
    }
    return NO;
}

+ (void) load
{
    [ABStandin addressBook];
}
@end
