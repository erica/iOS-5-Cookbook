/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ABGroup.h"
#import "ABContactsHelper.h"
#import "ABStandin.h"

@implementation ABGroup
@synthesize record;

// Thanks to Quentarez, Ciaran
- (id) initWithRecord: (ABRecordRef) aRecord
{
    if (self = [super init]) record = CFRetain(aRecord);
    return self;
}

- (void) dealloc
{
    if (record) 
        CFRelease(record);
}

+ (id) groupWithRecord: (ABRecordRef) grouprec
{
    return [[ABGroup alloc] initWithRecord:grouprec];
}

+ (id) groupWithRecordID: (ABRecordID) recordID
{
    ABAddressBookRef addressBook = [ABStandin addressBook];
    ABRecordRef grouprec = ABAddressBookGetGroupWithRecordID(addressBook, recordID);
    ABGroup *group = [self groupWithRecord:grouprec];
    return group;
}

// Thanks to Ciaran
+ (id) group
{
    ABRecordRef grouprec = ABGroupCreate();
    id group = [ABGroup groupWithRecord:grouprec];
    CFRelease(grouprec);
    return group;
}


// Thanks to Eridius for suggestions re: error
// Thanks Rincewind42 for the *error transfer bridging
- (BOOL) removeSelfFromAddressBook: (NSError **) error
{
    CFErrorRef cfError = NULL;
    BOOL success;
    
    ABAddressBookRef addressBook = [ABStandin addressBook];
    
    success = ABAddressBookRemoveRecord(addressBook, self.record, &cfError);
    if (!success)
    {
        if (error)
            *error = (__bridge_transfer NSError *)cfError;
        return NO;
    }

    return success;
}

#pragma mark Record ID and Type
- (ABRecordID) recordID {return ABRecordGetRecordID(record);}
- (ABRecordType) recordType {return ABRecordGetRecordType(record);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}

#pragma mark management
- (NSArray *) members
{
    NSArray *contacts = (__bridge_transfer NSArray *)ABGroupCopyArrayOfAllMembers(self.record);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
    for (id contact in contacts)
        [array addObject:[ABContact contactWithRecord:(__bridge ABRecordRef)contact]];
    return array;
}

// kABPersonSortByFirstName = 0, kABPersonSortByLastName  = 1
- (NSArray *) membersWithSorting: (ABPersonSortOrdering) ordering
{
    NSArray *contacts = (__bridge_transfer NSArray *)ABGroupCopyArrayOfAllMembersWithSortOrdering(self.record, ordering);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
    for (id contact in contacts)
        [array addObject:[ABContact contactWithRecord:(__bridge ABRecordRef)contact]];
    return array;
}

- (BOOL) addMember: (ABContact *) contact withError: (NSError **) error
{
    CFErrorRef cfError = NULL;
    BOOL success;
    
    success = ABGroupAddMember(self.record, contact.record, &cfError);
    if (!success)
    {
        if (error)
            *error = (__bridge_transfer NSError *)cfError;
        return NO;
    }
    
    return YES;
}

- (BOOL) removeMember: (ABContact *) contact withError: (NSError **) error
{
    CFErrorRef cfError = NULL;
    BOOL success;
    
    success = ABGroupRemoveMember(self.record, contact.record, &cfError);
    if (!success)
    {
        if (error)
            *error = (__bridge_transfer NSError *)cfError;
        return NO;
    }
    
    return YES;
}

#pragma mark name

- (NSString *) getRecordString:(ABPropertyID) anID
{
    return (__bridge_transfer NSString *) ABRecordCopyValue(record, anID);
}

- (NSString *) name
{
    return [self getRecordString:kABGroupNameProperty];
}

- (void) setName: (NSString *) aString
{
    CFErrorRef cfError = NULL;
    BOOL success;
    
    success = ABRecordSetValue(record, kABGroupNameProperty, (__bridge CFStringRef) aString, &cfError);
    if (!success)
    {
        NSError *error = (__bridge_transfer NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
}
@end
