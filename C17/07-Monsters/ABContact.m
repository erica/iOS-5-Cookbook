/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ABContact.h"
#import "ABContactsHelper.h"
#import "ABStandin.h"

@implementation ABContact
@synthesize record;

#pragma mark - Contacts

// Thanks to Quentarez, Ciaran
- (id) initWithRecord: (ABRecordRef) aRecord
{
    if (self = [super init]) 
        record = CFRetain(aRecord);
    return self;
}

+ (id) contactWithRecord: (ABRecordRef) person
{
    return [[ABContact alloc] initWithRecord:person];
}

+ (id) contactWithRecordID: (ABRecordID) recordID
{
    ABAddressBookRef addressBook = [ABStandin addressBook];
    ABRecordRef contactrec = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    if (!contactrec) return nil; // Thanks, Frederic Bronner

    ABContact *contact = [self contactWithRecord:contactrec];
    return contact;
}

// Thanks to Ciaran
+ (id) contact
{
    ABRecordRef person = ABPersonCreate();
    id contact = [ABContact contactWithRecord:person];
    CFRelease(person);
    return contact;
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

- (void) dealloc
{
    if (record) 
        CFRelease(record);
}

#pragma mark Sorting

- (BOOL) isEqualToString: (ABContact *) aContact
{
    return [self.compositeName isEqualToString:aContact.compositeName];
}

- (NSComparisonResult) caseInsensitiveCompare: (ABContact *) aContact
{
    return [self.compositeName caseInsensitiveCompare:aContact.compositeName];
}

#pragma mark Utilities
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty
{
    return (__bridge_transfer NSString *)ABPersonCopyLocalizedPropertyName(aProperty);
}

+ (ABPropertyType) propertyType: (ABPropertyID) aProperty
{
    return ABPersonGetTypeOfProperty(aProperty);
}

// Thanks to Eridius for switchification
+ (NSString *) propertyTypeString: (ABPropertyID) aProperty
{
    switch (ABPersonGetTypeOfProperty(aProperty))
    {
        case kABInvalidPropertyType: return @"Invalid Property";
        case kABStringPropertyType: return @"String";
        case kABIntegerPropertyType: return @"Integer";
        case kABRealPropertyType: return @"Float";
        case kABDateTimePropertyType: return DATE_STRING;
        case kABDictionaryPropertyType: return @"Dictionary";
        case kABMultiStringPropertyType: return @"Multi String";
        case kABMultiIntegerPropertyType: return @"Multi Integer";
        case kABMultiRealPropertyType: return @"Multi Float";
        case kABMultiDateTimePropertyType: return @"Multi Date";
        case kABMultiDictionaryPropertyType: return @"Multi Dictionary";
        default: return @"Invalid Property";
    }
}

+ (NSString *) propertyString: (ABPropertyID) aProperty
{
    if (aProperty == kABPersonFirstNameProperty) return FIRST_NAME_STRING;
    if (aProperty == kABPersonMiddleNameProperty) return MIDDLE_NAME_STRING;
    if (aProperty == kABPersonLastNameProperty) return LAST_NAME_STRING;

    if (aProperty == kABPersonPrefixProperty) return PREFIX_STRING;
    if (aProperty == kABPersonSuffixProperty) return SUFFIX_STRING;
    if (aProperty == kABPersonNicknameProperty) return NICKNAME_STRING;

    if (aProperty == kABPersonFirstNamePhoneticProperty) return PHONETIC_FIRST_STRING;
    if (aProperty == kABPersonMiddleNamePhoneticProperty) return PHONETIC_MIDDLE_STRING;
    if (aProperty == kABPersonLastNamePhoneticProperty) return PHONETIC_LAST_STRING;

    if (aProperty == kABPersonOrganizationProperty) return ORGANIZATION_STRING;
    if (aProperty == kABPersonJobTitleProperty) return JOBTITLE_STRING;
    if (aProperty == kABPersonDepartmentProperty) return DEPARTMENT_STRING;
    
    if (aProperty == kABPersonNoteProperty) return NOTE_STRING;

    if (aProperty == kABPersonKindProperty) return KIND_STRING;

    if (aProperty == kABPersonBirthdayProperty) return BIRTHDAY_STRING;
    if (aProperty == kABPersonCreationDateProperty) return CREATION_DATE_STRING;
    if (aProperty == kABPersonModificationDateProperty) return MODIFICATION_DATE_STRING;

    if (aProperty == kABPersonEmailProperty) return EMAIL_STRING;
    if (aProperty == kABPersonAddressProperty) return ADDRESS_STRING;
    if (aProperty == kABPersonDateProperty) return DATE_STRING;
    if (aProperty == kABPersonPhoneProperty) return PHONE_STRING;
    if (aProperty == kABPersonInstantMessageProperty) return IM_STRING;
    if (aProperty == kABPersonURLProperty) return URL_STRING;
    if (aProperty == kABPersonSocialProfileProperty) return SOCIAL_STRING;
    if (aProperty == kABPersonRelatedNamesProperty) return RELATED_STRING;

    return nil;
}

+ (NSArray *) arrayForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record
{
    // Recover the property for a given record
    CFTypeRef theProperty = ABRecordCopyValue(record, anID);
    NSArray *items = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
    CFRelease(theProperty);
    return items;
}

+ (id) objectForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record
{
    return (__bridge_transfer id) ABRecordCopyValue(record, anID);
}

#pragma mark Record ID and Type

- (ABRecordID) recordID {return ABRecordGetRecordID(record);}
- (ABRecordType) recordType {return ABRecordGetRecordType(record);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}

#pragma mark String Retrieval

- (NSString *) getRecordString:(ABPropertyID) anID
{
    NSString *result = (__bridge_transfer NSString *) ABRecordCopyValue(record, anID);
    return result;
}
- (NSString *) firstname {return [self getRecordString:kABPersonFirstNameProperty];}
- (NSString *) middlename {return [self getRecordString:kABPersonMiddleNameProperty];}
- (NSString *) lastname {return [self getRecordString:kABPersonLastNameProperty];}

- (NSString *) prefix {return [self getRecordString:kABPersonPrefixProperty];}
- (NSString *) suffix {return [self getRecordString:kABPersonSuffixProperty];}
- (NSString *) nickname {return [self getRecordString:kABPersonNicknameProperty];}

- (NSString *) firstnamephonetic {return [self getRecordString:kABPersonFirstNamePhoneticProperty];}
- (NSString *) middlenamephonetic {return [self getRecordString:kABPersonMiddleNamePhoneticProperty];}
- (NSString *) lastnamephonetic {return [self getRecordString:kABPersonLastNamePhoneticProperty];}

- (NSString *) organization {return [self getRecordString:kABPersonOrganizationProperty];}
- (NSString *) jobtitle {return [self getRecordString:kABPersonJobTitleProperty];}
- (NSString *) department {return [self getRecordString:kABPersonDepartmentProperty];}
- (NSString *) note {return [self getRecordString:kABPersonNoteProperty];}


#pragma mark Setting Strings
- (BOOL) setString: (NSString *) aString forProperty:(ABPropertyID) anID
{
    CFErrorRef cfError = NULL;
    BOOL success = ABRecordSetValue(record, anID, (__bridge CFStringRef) aString, &cfError);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

- (void) setFirstname: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNameProperty];}
- (void) setMiddlename: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNameProperty];}
- (void) setLastname: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNameProperty];}

- (void) setPrefix: (NSString *) aString {[self setString: aString forProperty: kABPersonPrefixProperty];}
- (void) setSuffix: (NSString *) aString {[self setString: aString forProperty: kABPersonSuffixProperty];}
- (void) setNickname: (NSString *) aString {[self setString: aString forProperty: kABPersonNicknameProperty];}

- (void) setFirstnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNamePhoneticProperty];}
- (void) setMiddlenamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNamePhoneticProperty];}
- (void) setLastnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNamePhoneticProperty];}

- (void) setOrganization: (NSString *) aString {[self setString: aString forProperty: kABPersonOrganizationProperty];}
- (void) setJobtitle: (NSString *) aString {[self setString: aString forProperty: kABPersonJobTitleProperty];}
- (void) setDepartment: (NSString *) aString {[self setString: aString forProperty: kABPersonDepartmentProperty];}

- (void) setNote: (NSString *) aString {[self setString: aString forProperty: kABPersonNoteProperty];}

#pragma mark Contact Name
- (NSString *) contactName
{
    NSMutableString *string = [NSMutableString string];
    
    if (self.firstname || self.lastname)
    {
        if (self.prefix) [string appendFormat:@"%@ ", self.prefix];
        if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
        if (self.nickname) [string appendFormat:@"\"%@\" ", self.nickname];
        if (self.lastname) [string appendFormat:@"%@", self.lastname];
        
        if (self.suffix && string.length)
            [string appendFormat:@", %@ ", self.suffix];
        else
            [string appendFormat:@" "];
    }
    
    if (self.organization) [string appendString:self.organization];
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) compositeName
{
    return (__bridge_transfer NSString *)ABRecordCopyCompositeName(record);
}

#pragma mark Numbers

- (NSNumber *) getRecordNumber: (ABPropertyID) anID
{
    return (__bridge_transfer NSNumber *) ABRecordCopyValue(record, anID);
}

- (NSNumber *) kind {return [self getRecordNumber:kABPersonKindProperty];}


#pragma mark Setting Numbers
- (BOOL) setNumber: (NSNumber *) aNumber forProperty:(ABPropertyID) anID
{
    CFErrorRef cfError = NULL;
    BOOL success = ABRecordSetValue(record, anID, (__bridge CFNumberRef) aNumber, &cfError);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

// const CFNumberRef kABPersonKindPerson;
// const CFNumberRef kABPersonKindOrganization;
- (void) setKind: (NSNumber *) aKind {[self setNumber:aKind forProperty: kABPersonKindProperty];}

#pragma mark Dates

- (NSDate *) getRecordDate:(ABPropertyID) anID
{
    return (__bridge_transfer NSDate *) ABRecordCopyValue(record, anID);
}

- (NSDate *) birthday {return [self getRecordDate:kABPersonBirthdayProperty];}
- (NSDate *) creationDate {return [self getRecordDate:kABPersonCreationDateProperty];}
- (NSDate *) modificationDate {return [self getRecordDate:kABPersonModificationDateProperty];}

#pragma mark Setting Dates

- (BOOL) setDate: (NSDate *) aDate forProperty:(ABPropertyID) anID
{
    CFErrorRef cfError = NULL;
    BOOL success = ABRecordSetValue(record, anID, (__bridge CFDateRef) aDate, &cfError);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

- (void) setBirthday: (NSDate *) aDate {[self setDate: aDate forProperty: kABPersonBirthdayProperty];}


#pragma mark Images

- (UIImage *) image
{
    if (!ABPersonHasImageData(record)) return nil;
    CFDataRef imageData = ABPersonCopyImageData(record);
    if (!imageData) return nil;
    
    NSData *data = (__bridge_transfer NSData *)imageData;
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

- (void) setImage: (UIImage *) image
{
    CFErrorRef cfError = NULL;
    BOOL success;
    
    if (image == nil) // remove
    {
        if (!ABPersonHasImageData(record)) return; // no image to remove
        success = ABPersonRemoveImageData(record, &cfError);
        if (!success) 
        {
            NSError *error = (__bridge_transfer NSError *) cfError;
            NSLog(@"Error: %@", error.localizedFailureReason);
        }
        return;
    }
    
    NSData *data = UIImagePNGRepresentation(image);
    success = ABPersonSetImageData(record, (__bridge CFDataRef) data, &cfError);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return;
}

#pragma mark MultiValue
+ (BOOL) propertyIsMultiValue: (ABPropertyID) aProperty;
{
    if (aProperty == kABPersonFirstNameProperty) return NO;
    if (aProperty == kABPersonMiddleNameProperty) return NO;
    if (aProperty == kABPersonLastNameProperty) return NO;
    
    if (aProperty == kABPersonPrefixProperty) return NO;
    if (aProperty == kABPersonSuffixProperty) return NO;
    if (aProperty == kABPersonNicknameProperty) return NO;
    
    if (aProperty == kABPersonFirstNamePhoneticProperty) return NO;
    if (aProperty == kABPersonMiddleNamePhoneticProperty) return NO;
    if (aProperty == kABPersonLastNamePhoneticProperty) return NO;
    
    if (aProperty == kABPersonOrganizationProperty) return NO;
    if (aProperty == kABPersonJobTitleProperty) return NO;
    if (aProperty == kABPersonDepartmentProperty) return NO;
    
    if (aProperty == kABPersonNoteProperty) return NO;
    
    if (aProperty == kABPersonKindProperty) return NO;
    
    if (aProperty == kABPersonBirthdayProperty) return NO;
    if (aProperty == kABPersonCreationDateProperty) return NO;
    if (aProperty == kABPersonModificationDateProperty) return NO;
    
    return YES;
    
    /*
     if (aProperty == kABPersonEmailProperty) return YES; // multistring
     if (aProperty == kABPersonPhoneProperty) return YES; // multistring
     if (aProperty == kABPersonURLProperty) return YES; // multistring

     if (aProperty == kABPersonAddressProperty) return YES; // multivalue
     if (aProperty == kABPersonDateProperty) return YES; // multivalue
     if (aProperty == kABPersonInstantMessageProperty) return YES; // multivalue
     if (aProperty == kABPersonRelatedNamesProperty) return YES; // multivalue
     if (aProperty == kABPersonSocialProfileProperty) return YES; // multivalue
     */
}

// Determine whether the dictionary is a proper value/label item
+ (BOOL) isMultivalueDictionary: (NSDictionary *) dictionary
{
    if (dictionary.allKeys.count != 2) 
        return NO;
    if (![dictionary objectForKey:@"value"])
        return NO;
    if (![dictionary objectForKey:@"label"])
        return NO;
    
    return YES;
}

// Return multivalue-style dictionary
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (value) [dict setObject:value forKey:@"value"];
    if (label) [dict setObject:(__bridge NSString *)label forKey:@"label"];
    return dict;
}

#pragma mark Accessing MultiValue Elements (value and label)

- (NSArray *) arrayForProperty: (ABPropertyID) anID
{
    CFTypeRef theProperty = ABRecordCopyValue(record, anID);
    if (!theProperty) return nil;
    
    NSArray *items = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
    CFRelease(theProperty);
    return items;
}

- (NSArray *) labelsForProperty: (ABPropertyID) anID
{
    CFTypeRef theProperty = ABRecordCopyValue(record, anID);
    if (!theProperty) return nil;

    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < ABMultiValueGetCount(theProperty); i++)
    {
        NSString *label = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
        [labels addObject:label];
    }
    CFRelease(theProperty);
    return labels;
}

- (NSArray *) emailArray {return [self arrayForProperty:kABPersonEmailProperty];}
- (NSArray *) emailLabels {return [self labelsForProperty:kABPersonEmailProperty];}

- (NSArray *) phoneArray {return [self arrayForProperty:kABPersonPhoneProperty];}
- (NSArray *) phoneLabels {return [self labelsForProperty:kABPersonPhoneProperty];}

- (NSArray *) relatedNameArray {return [self arrayForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) relatedNameLabels {return [self labelsForProperty:kABPersonRelatedNamesProperty];}

- (NSArray *) urlArray {return [self arrayForProperty:kABPersonURLProperty];}
- (NSArray *) urlLabels {return [self labelsForProperty:kABPersonURLProperty];}

- (NSArray *) dateArray {return [self arrayForProperty:kABPersonDateProperty];}
- (NSArray *) dateLabels {return [self labelsForProperty:kABPersonDateProperty];}

- (NSArray *) addressArray {return [self arrayForProperty:kABPersonAddressProperty];}
- (NSArray *) addressLabels {return [self labelsForProperty:kABPersonAddressProperty];}

- (NSArray *) imArray {return [self arrayForProperty:kABPersonInstantMessageProperty];}
- (NSArray *) imLabels {return [self labelsForProperty:kABPersonInstantMessageProperty];}

- (NSArray *) socialArray {return [self arrayForProperty:kABPersonSocialProfileProperty];}
- (NSArray *) socialLabels {return [self labelsForProperty:kABPersonSocialProfileProperty];}

// Multi-string convenience
- (NSString *) phonenumbers {return [self.phoneArray componentsJoinedByString:@" "];}
- (NSString *) emailaddresses {return [self.emailArray componentsJoinedByString:@" "];}
- (NSString *) urls {return [self.urlArray componentsJoinedByString:@" "];}

// MultiValue convenience
- (NSArray *) dictionaryArrayForProperty: (ABPropertyID) aProperty
{
    NSArray *valueArray = [self arrayForProperty:aProperty];
    NSArray *labelArray = [self labelsForProperty:aProperty];
    
    int num = MIN(valueArray.count, labelArray.count);
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < num; i++)
    {
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        [md setObject:[valueArray objectAtIndex:i] forKey:@"value"];
        [md setObject:[labelArray objectAtIndex:i] forKey:@"label"];
        [items addObject:md];
    }
    return items;
}

#pragma mark MultiValue Dictionary Arrays

- (NSArray *) emailDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonEmailProperty];
}

- (NSArray *) phoneDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonPhoneProperty];
}

- (NSArray *) relatedNameDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonRelatedNamesProperty];
}

- (NSArray *) urlDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonURLProperty];
}

- (NSArray *) dateDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonDateProperty];
}

- (NSArray *) addressDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonAddressProperty];
}

- (NSArray *) imDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonInstantMessageProperty];
}

- (NSArray *) socialDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonSocialProfileProperty];
}

#pragma mark Building Addresses, Social, and IM

/*
// kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
// kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
*/
+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
                           withState:(NSString *) state withZip: (NSString *) zip
                         withCountry: (NSString *) country withCode: (NSString *) code
{
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if (street) [md setObject:street forKey:(__bridge NSString *) kABPersonAddressStreetKey];
    if (city) [md setObject:city forKey:(__bridge NSString *) kABPersonAddressCityKey];
    if (state) [md setObject:state forKey:(__bridge NSString *) kABPersonAddressStateKey];
    if (zip) [md setObject:zip forKey:(__bridge NSString *) kABPersonAddressZIPKey];
    if (country) [md setObject:country forKey:(__bridge NSString *) kABPersonAddressCountryKey];
    if (code) [md setObject:code forKey:(__bridge NSString *) kABPersonAddressCountryCodeKey];
    return md;
}

/*
 Service Names:
 const CFStringRef kABPersonSocialProfileServiceTwitter;
 const CFStringRef kABPersonSocialProfileServiceGameCenter;
 const CFStringRef kABPersonSocialProfileServiceFacebook;
 const CFStringRef kABPersonSocialProfileServiceMyspace;
 const CFStringRef kABPersonSocialProfileServiceLinkedIn;
 const CFStringRef kABPersonSocialProfileServiceFlickr;
*/
+ (NSDictionary *) socialWithURL: (NSString *) url withService: (NSString *) serviceName 
                    withUsername: (NSString *) username withIdentifier: (NSString *) key
{
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if (url) [md setObject:url forKey:(__bridge NSString *) kABPersonSocialProfileURLKey];
    if (serviceName) [md setObject:serviceName forKey:(__bridge NSString *) kABPersonSocialProfileServiceKey];
    if (username) [md setObject:username forKey:(__bridge NSString *) kABPersonSocialProfileUsernameKey];
    if (key) [md setObject:key forKey:(__bridge NSString *) kABPersonSocialProfileUserIdentifierKey];
    return md;
}

/*
 // kABWorkLabel, kABHomeLabel, kABOtherLabel, 
 const CFStringRef kABPersonInstantMessageServiceYahoo;
 const CFStringRef kABPersonInstantMessageServiceJabber;
 const CFStringRef kABPersonInstantMessageServiceMSN;
 const CFStringRef kABPersonInstantMessageServiceICQ;
 const CFStringRef kABPersonInstantMessageServiceAIM;
 const CFStringRef kABPersonInstantMessageServiceFacebook;
 const CFStringRef kABPersonInstantMessageServiceGaduGadu;
 const CFStringRef kABPersonInstantMessageServiceGoogleTalk;
 const CFStringRef kABPersonInstantMessageServiceQQ;
 const CFStringRef kABPersonInstantMessageServiceSkype;
*/
+ (NSDictionary *) imWithService: (CFStringRef) service andUser: (NSString *) userName
{
    NSMutableDictionary *im = [NSMutableDictionary dictionary];
    if (service) [im setObject:(__bridge NSString *) service forKey:(__bridge NSString *) kABPersonInstantMessageServiceKey];
    if (userName) [im setObject:userName forKey:(__bridge NSString *) kABPersonInstantMessageUsernameKey];
    return im;
}

#pragma mark MultiValue Addition Utilities

- (BOOL) addAddress: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;

    NSArray *current = self.addressDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.addressDictionaries = mutable;

    return YES;
}

- (BOOL) addAddressItem:(NSDictionary *)dictionary withLabel: (CFStringRef) label
{
    if (!dictionary) return NO;
    if ([ABContact isMultivalueDictionary:dictionary]) 
        return [self addAddress:dictionary];
    
    NSDictionary *multi = [ABContact dictionaryWithValue:dictionary andLabel:label];
    return [self addAddress:multi];
}

- (BOOL) addIM: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.imDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.imDictionaries = mutable;
    
    return YES;
}

- (BOOL) addIMItem:(NSDictionary *)dictionary withLabel: (CFStringRef) label
{
    if (!dictionary) return NO;
    if ([ABContact isMultivalueDictionary:dictionary]) 
        return [self addIM:dictionary];
    
    NSDictionary *multi = [ABContact dictionaryWithValue:dictionary andLabel:label];
    return [self addIM:multi];
}


- (BOOL) addEmail: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.emailDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.emailDictionaries = mutable;
    
    return YES;
}

- (BOOL) addEmailItem: (NSString *) value withLabel: (CFStringRef) label
{
    if (!value) return NO;
    NSDictionary *multi = [ABContact dictionaryWithValue:value andLabel:label];
    return [self addEmail:multi];
}

- (BOOL) addPhone: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.phoneDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.phoneDictionaries = mutable;
    
    return YES;
}

- (BOOL) addPhoneItem: (NSString *) value withLabel: (CFStringRef) label
{
    if (!value) return NO;
    NSDictionary *multi = [ABContact dictionaryWithValue:value andLabel:label];
    return [self addPhone:multi];
}

- (BOOL) addURL: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.urlDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.urlDictionaries = mutable;
    
    return YES;
}

- (BOOL) addURLItem: (NSString *) value withLabel: (CFStringRef) label
{
    if (!value) return NO;
    NSDictionary *multi = [ABContact dictionaryWithValue:value andLabel:label];
    return [self addURL:multi];
}

- (BOOL) addSocial: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.socialDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.socialDictionaries = mutable;
    
    return YES;
}

- (BOOL) addSocialItem: (NSDictionary *) dictionary withLabel: (CFStringRef) label
{
    if (!dictionary) return NO;
    if ([ABContact isMultivalueDictionary:dictionary]) 
        return [self addSocial:dictionary];
    
    NSDictionary *multi = [ABContact dictionaryWithValue:dictionary andLabel:label];
    return [self addSocial:multi];
}

#pragma mark Setting MultiValue

- (BOOL) setMultiValue: (ABMutableMultiValueRef) multi forProperty: (ABPropertyID) anID
{
    CFErrorRef cfError = NULL;
    BOOL success = ABRecordSetValue(record, anID, multi, &cfError);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

- (ABMutableMultiValueRef) copyMultiValueFromArray: (NSArray *) anArray withType: (ABPropertyType) aType
{
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(aType);
    for (NSDictionary *dict in anArray)
    {
        if (![ABContact isMultivalueDictionary:dict])
            continue;
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dict objectForKey:@"value"], (__bridge CFTypeRef) [dict objectForKey:@"label"], NULL);
    }
    return multi;
}

- (void) setEmailDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonEmailProperty];
    CFRelease(multi);
}

- (void) setPhoneDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
    // kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
    // kABPersonPhoneOtherFAXLabel

    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonPhoneProperty];
    CFRelease(multi);
}

- (void) setUrlDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonHomePageLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonURLProperty];
    CFRelease(multi);
}

// Not used/shown on iPhone
- (void) setRelatedNameDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonMotherLabel, kABPersonFatherLabel, kABPersonParentLabel, 
    // kABPersonSisterLabel, kABPersonBrotherLabel, kABPersonChildLabel, 
    // kABPersonFriendLabel, kABPersonSpouseLabel, kABPersonPartnerLabel, 
    // kABPersonManagerLabel, kABPersonAssistantLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonRelatedNamesProperty];
    CFRelease(multi);
}

- (void) setDateDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonAnniversaryLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDateTimePropertyType];
    [self setMultiValue:multi forProperty:kABPersonDateProperty];
    CFRelease(multi);
}

- (void) setAddressDictionaries: (NSArray *) dictionaries
{
    // kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
    // kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMultiValue:multi forProperty:kABPersonAddressProperty];
    CFRelease(multi);
}

- (void) setImDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel, 
    // kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
    // kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
    // kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
    // kABPersonInstantMessageServiceAIM, 
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMultiValue:multi forProperty:kABPersonInstantMessageProperty];
    CFRelease(multi);
}

- (void) setSocialDictionaries:(NSArray *)dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel, 
    // kABPersonSocialProfileServiceTwitter
    // kABPersonSocialProfileServiceGameCenter
    // kABPersonSocialProfileServiceFacebook
    // kABPersonSocialProfileServiceMyspace
    // kABPersonSocialProfileServiceLinkedIn
    // kABPersonSocialProfileServiceFlickr

    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMultiValue:multi forProperty:kABPersonSocialProfileProperty];
    CFRelease(multi);
}

#pragma mark Representations

// No Image
- (NSDictionary *) baseDictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.firstname) [dict setObject:self.firstname forKey:FIRST_NAME_STRING];
    if (self.middlename) [dict setObject:self.middlename forKey:MIDDLE_NAME_STRING];
    if (self.lastname) [dict setObject:self.lastname forKey:LAST_NAME_STRING];

    if (self.prefix) [dict setObject:self.prefix forKey:PREFIX_STRING];
    if (self.suffix) [dict setObject:self.suffix forKey:SUFFIX_STRING];
    if (self.nickname) [dict setObject:self.nickname forKey:NICKNAME_STRING];
    
    if (self.firstnamephonetic) [dict setObject:self.firstnamephonetic forKey:PHONETIC_FIRST_STRING];
    if (self.middlenamephonetic) [dict setObject:self.middlenamephonetic forKey:PHONETIC_MIDDLE_STRING];
    if (self.lastnamephonetic) [dict setObject:self.lastnamephonetic forKey:PHONETIC_LAST_STRING];
    
    if (self.organization) [dict setObject:self.organization forKey:ORGANIZATION_STRING];
    if (self.jobtitle) [dict setObject:self.jobtitle forKey:JOBTITLE_STRING];
    if (self.department) [dict setObject:self.department forKey:DEPARTMENT_STRING];
    
    if (self.note) [dict setObject:self.note forKey:NOTE_STRING];

    if (self.kind) [dict setObject:self.kind forKey:KIND_STRING];

    if (self.birthday) [dict setObject:self.birthday forKey:BIRTHDAY_STRING];
    if (self.creationDate) [dict setObject:self.creationDate forKey:CREATION_DATE_STRING];
    if (self.modificationDate) [dict setObject:self.modificationDate forKey:MODIFICATION_DATE_STRING];

    [dict setObject:self.emailDictionaries forKey:EMAIL_STRING];
    [dict setObject:self.addressDictionaries forKey:ADDRESS_STRING];
    [dict setObject:self.dateDictionaries forKey:DATE_STRING];
    [dict setObject:self.phoneDictionaries forKey:PHONE_STRING];
    [dict setObject:self.imDictionaries forKey:IM_STRING];
    [dict setObject:self.urlDictionaries forKey:URL_STRING];
    [dict setObject:self.relatedNameDictionaries forKey:RELATED_STRING];
    
    return dict;
}

// With image where available
- (NSDictionary *) dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self baseDictionaryRepresentation]];
    if (ABPersonHasImageData(record)) 
    {
        CFDataRef imageData = ABPersonCopyImageData(record);
        NSData *data = (__bridge_transfer NSData *)imageData;
        [dict setObject:data forKey:IMAGE_STRING];
    }
    return dict;
}

// No Image
- (NSData *) baseDataRepresentation
{
    NSString *errorString;
    NSDictionary *dict = [self baseDictionaryRepresentation];
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
    if (!data) 
        NSLog(@"Error: %@", errorString);
    return data; 
}


// With image where available
- (NSData *) dataRepresentation
{
    NSString *errorString;
    NSDictionary *dict = [self dictionaryRepresentation];
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
    if (!data) 
        NSLog(@"Error: %@", errorString);
    return data;
}

+ (id) contactWithDictionary: (NSDictionary *) dict
{
    ABContact *contact = [ABContact contact];
    if ([dict objectForKey:FIRST_NAME_STRING]) 
        contact.firstname = [dict objectForKey:FIRST_NAME_STRING];
    if ([dict objectForKey:MIDDLE_NAME_STRING]) 
        contact.middlename = [dict objectForKey:MIDDLE_NAME_STRING];
    if ([dict objectForKey:LAST_NAME_STRING]) 
        contact.lastname = [dict objectForKey:LAST_NAME_STRING];
    
    if ([dict objectForKey:PREFIX_STRING]) 
        contact.prefix = [dict objectForKey:PREFIX_STRING];
    if ([dict objectForKey:SUFFIX_STRING]) 
        contact.suffix = [dict objectForKey:SUFFIX_STRING];
    if ([dict objectForKey:NICKNAME_STRING]) 
        contact.nickname = [dict objectForKey:NICKNAME_STRING];
    
    if ([dict objectForKey:PHONETIC_FIRST_STRING]) 
        contact.firstnamephonetic = [dict objectForKey:PHONETIC_FIRST_STRING];
    if ([dict objectForKey:PHONETIC_MIDDLE_STRING]) 
        contact.middlenamephonetic = [dict objectForKey:PHONETIC_MIDDLE_STRING];
    if ([dict objectForKey:PHONETIC_LAST_STRING]) 
        contact.lastnamephonetic = [dict objectForKey:PHONETIC_LAST_STRING];
    
    if ([dict objectForKey:ORGANIZATION_STRING]) 
        contact.organization = [dict objectForKey:ORGANIZATION_STRING];
    if ([dict objectForKey:JOBTITLE_STRING]) 
        contact.jobtitle = [dict objectForKey:JOBTITLE_STRING];
    if ([dict objectForKey:DEPARTMENT_STRING]) 
        contact.department = [dict objectForKey:DEPARTMENT_STRING];
    
    if ([dict objectForKey:NOTE_STRING]) 
        contact.note = [dict objectForKey:NOTE_STRING];
    
    if ([dict objectForKey:KIND_STRING]) 
        contact.kind = [dict objectForKey:KIND_STRING];

    if ([dict objectForKey:EMAIL_STRING]) 
        contact.emailDictionaries = [dict objectForKey:EMAIL_STRING];
    if ([dict objectForKey:ADDRESS_STRING]) 
        contact.addressDictionaries = [dict objectForKey:ADDRESS_STRING];
    if ([dict objectForKey:DATE_STRING]) 
        contact.dateDictionaries = [dict objectForKey:DATE_STRING];
    if ([dict objectForKey:PHONE_STRING]) 
        contact.phoneDictionaries = [dict objectForKey:PHONE_STRING];
    if ([dict objectForKey:IM_STRING]) 
        contact.imDictionaries = [dict objectForKey:IM_STRING];
    if ([dict objectForKey:URL_STRING]) 
        contact.urlDictionaries = [dict objectForKey:URL_STRING];
    if ([dict objectForKey:RELATED_STRING]) 
        contact.relatedNameDictionaries = [dict objectForKey:RELATED_STRING];

    if ([dict objectForKey:IMAGE_STRING]) 
    {
        CFErrorRef cfError = NULL;
         BOOL success = ABPersonSetImageData(contact.record, (__bridge CFDataRef) [dict objectForKey:IMAGE_STRING], &cfError);
        if (!success) 
        {
            NSError *error = (__bridge_transfer NSError *) cfError;
            NSLog(@"Error: %@", error.localizedFailureReason);
        }
    }

    return contact;
}

+ (id) contactWithData: (NSData *) data
{
    // Otherwise handle points
    CFStringRef errorString;
    CFPropertyListRef plist = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFPropertyListMutableContainers, &errorString);
    if (!plist) 
    {
        CFShow(errorString);
        return nil;
    }
    
    NSDictionary *dict = (__bridge_transfer NSDictionary *) plist;
    return [self contactWithDictionary:dict];
}
@end