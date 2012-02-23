/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


#pragma mark - Human Readable Name Strings for Dictionary Conversion

#define FIRST_NAME_STRING	@"First Name"
#define MIDDLE_NAME_STRING	@"Middle Name"
#define LAST_NAME_STRING	@"Last Name"

#define PREFIX_STRING	@"Prefix"
#define SUFFIX_STRING	@"Suffix"
#define NICKNAME_STRING	@"Nickname"

#define PHONETIC_FIRST_STRING	@"Phonetic First Name"
#define PHONETIC_MIDDLE_STRING	@"Phonetic Middle Name"
#define PHONETIC_LAST_STRING	@"Phonetic Last Name"

#define ORGANIZATION_STRING	@"Organization"
#define JOBTITLE_STRING		@"Job Title"
#define DEPARTMENT_STRING	@"Department"

#define NOTE_STRING	@"Note"

#define BIRTHDAY_STRING				@"Birthday"
#define CREATION_DATE_STRING		@"Creation Date"
#define MODIFICATION_DATE_STRING	@"Modification Date"

#define KIND_STRING	@"Kind"

#define EMAIL_STRING	@"Email"
#define ADDRESS_STRING	@"Address"
#define DATE_STRING		@"Date"
#define PHONE_STRING	@"Phone"
#define IM_STRING		@"Instant Message"
#define URL_STRING		@"URL"
#define RELATED_STRING	@"Related Name"
#define SOCIAL_STRING   @"Social Profile"

#define IMAGE_STRING	@"Image"

#pragma mark Label Quick Reference

/*
 // Generic
 const CFStringRef kABWorkLabel;
 const CFStringRef kABHomeLabel;
 const CFStringRef kABOtherLabel;
 
 // Relation
 const CFStringRef kABPersonMotherLabel;
 const CFStringRef kABPersonFatherLabel;
 const CFStringRef kABPersonParentLabel;
 const CFStringRef kABPersonSisterLabel;
 const CFStringRef kABPersonBrotherLabel;
 const CFStringRef kABPersonChildLabel;
 const CFStringRef kABPersonFriendLabel;
 const CFStringRef kABPersonSpouseLabel;
 const CFStringRef kABPersonPartnerLabel;
 const CFStringRef kABPersonManagerLabel;
 const CFStringRef kABPersonAssistantLabel;
 
 // URL
 const CFStringRef kABPersonHomePageLabel;
 
 // Social
 const CFStringRef kABPersonSocialProfileServiceTwitter;
 const CFStringRef kABPersonSocialProfileServiceGameCenter;
 const CFStringRef kABPersonSocialProfileServiceFacebook;
 const CFStringRef kABPersonSocialProfileServiceMyspace;
 const CFStringRef kABPersonSocialProfileServiceLinkedIn;
 const CFStringRef kABPersonSocialProfileServiceFlickr;
 
 // IM
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
 
 // Phone Numbers
 const CFStringRef kABPersonPhoneMobileLabel;
 const CFStringRef kABPersonPhoneIPhoneLabel;
 const CFStringRef kABPersonPhoneMainLabel;
 const CFStringRef kABPersonPhoneHomeFAXLabel;
 const CFStringRef kABPersonPhoneWorkFAXLabel;
 const CFStringRef kABPersonPhonePagerLabel;
 const CFStringRef kABPersonPhoneOtherFAXLabel;
 
 // Date
 const CFStringRef kABPersonAnniversaryLabel;
*/

#pragma mark ABContact

@interface ABContact : NSObject
{
	ABRecordRef record;
}

// Convenience allocation methods
+ (id) contact;
+ (id) contactWithRecord: (ABRecordRef) record;
+ (id) contactWithRecordID: (ABRecordID) recordID;

// Class utility methods
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty;
+ (ABPropertyType) propertyType: (ABPropertyID) aProperty;
+ (NSString *) propertyTypeString: (ABPropertyID) aProperty;
+ (NSString *) propertyString: (ABPropertyID) aProperty;
+ (BOOL) propertyIsMultiValue: (ABPropertyID) aProperty;
+ (NSArray *) arrayForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record;
+ (id) objectForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record;

// Creating proper dictionaries
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label;
+ (BOOL) isMultivalueDictionary: (NSDictionary *) dictionary;
+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city withState:(NSString *) state withZip: (NSString *) zip withCountry: (NSString *) country withCode: (NSString *) code;
+ (NSDictionary *) imWithService: (CFStringRef) service andUser: (NSString *) userName;
+ (NSDictionary *) socialWithURL: (NSString *) url withService: (NSString *) serviceName withUsername: (NSString *) username withIdentifier: (NSString *) key;

// Instance utility methods
- (BOOL) removeSelfFromAddressBook: (NSError **) error;

- (BOOL) addAddress: (NSDictionary *) dictionary;
- (BOOL) addAddressItem:(NSDictionary *)dictionary withLabel: (CFStringRef) label;
- (BOOL) addSocial: (NSDictionary *) dictionary;
- (BOOL) addSocialItem: (NSDictionary *) dictionary withLabel: (CFStringRef) label;
- (BOOL) addIM: (NSDictionary *) dictionary;
- (BOOL) addIMItem:(NSDictionary *)dictionary withLabel: (CFStringRef) label;

- (BOOL) addEmail: (NSDictionary *) dictionary;
- (BOOL) addEmailItem: (NSString *) value withLabel: (CFStringRef) label;
- (BOOL) addPhone: (NSDictionary *) dictionary;
- (BOOL) addPhoneItem: (NSString *) value withLabel: (CFStringRef) label;
- (BOOL) addURL: (NSDictionary *) dictionary;
- (BOOL) addURLItem: (NSString *) value withLabel: (CFStringRef) label;

// Sorting
- (BOOL) isEqualToString: (ABContact *) aContact;
- (NSComparisonResult) caseInsensitiveCompare: (ABContact *) aContact;

#pragma mark RECORD ACCESS
@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, readonly) ABRecordID recordID;
@property (nonatomic, readonly) ABRecordType recordType;
@property (nonatomic, readonly) BOOL isPerson;

#pragma mark SINGLE VALUE STRING
@property (nonatomic, assign) NSString *firstname;
@property (nonatomic, assign) NSString *lastname;
@property (nonatomic, assign) NSString *middlename;
@property (nonatomic, assign) NSString *prefix;
@property (nonatomic, assign) NSString *suffix;
@property (nonatomic, assign) NSString *nickname;
@property (nonatomic, assign) NSString *firstnamephonetic;
@property (nonatomic, assign) NSString *lastnamephonetic;
@property (nonatomic, assign) NSString *middlenamephonetic;
@property (nonatomic, assign) NSString *organization;
@property (nonatomic, assign) NSString *jobtitle;
@property (nonatomic, assign) NSString *department;
@property (nonatomic, assign) NSString *note;

@property (nonatomic, readonly) NSString *contactName; // my friendly utility
@property (nonatomic, readonly) NSString *compositeName; // via AB

#pragma mark NUMBER
@property (nonatomic, assign) NSNumber *kind;

#pragma mark DATE
@property (nonatomic, assign) NSDate *birthday;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSDate *modificationDate;

#pragma mark IMAGES
@property (nonatomic, assign) UIImage *image;

#pragma mark MULTIVALUE
@property (nonatomic, readonly) NSArray *emailArray;
@property (nonatomic, readonly) NSArray *emailLabels;
@property (nonatomic, readonly) NSArray *phoneArray;
@property (nonatomic, readonly) NSArray *phoneLabels;
@property (nonatomic, readonly) NSArray *relatedNameArray;
@property (nonatomic, readonly) NSArray *relatedNameLabels;
@property (nonatomic, readonly) NSArray *urlArray;
@property (nonatomic, readonly) NSArray *urlLabels;
@property (nonatomic, readonly) NSArray *dateArray;
@property (nonatomic, readonly) NSArray *dateLabels;
@property (nonatomic, readonly) NSArray *addressArray;
@property (nonatomic, readonly) NSArray *addressLabels;
@property (nonatomic, readonly) NSArray *imArray;
@property (nonatomic, readonly) NSArray *imLabels;
@property (nonatomic, readonly) NSArray *socialArray;
@property (nonatomic, readonly) NSArray *socialLabels;

// Each of these produces an array of strings
@property (nonatomic, readonly) NSString *emailaddresses;
@property (nonatomic, readonly) NSString *phonenumbers;
@property (nonatomic, readonly) NSString *urls;

// Each of these uses an array of dictionaries
@property (nonatomic, assign) NSArray *emailDictionaries;
@property (nonatomic, assign) NSArray *phoneDictionaries;
@property (nonatomic, assign) NSArray *relatedNameDictionaries;
@property (nonatomic, assign) NSArray *urlDictionaries;
@property (nonatomic, assign) NSArray *dateDictionaries;
@property (nonatomic, assign) NSArray *addressDictionaries;
@property (nonatomic, assign) NSArray *imDictionaries;
@property (nonatomic, assign) NSArray *socialDictionaries;

#pragma mark REPRESENTATIONS
// Conversion to dictionary
@property (nonatomic, readonly) NSDictionary *baseDictionaryRepresentation; // no image
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation; // image where available

// Conversion to data
@property (nonatomic, readonly) NSData *baseDataRepresentation; // no image
@property (nonatomic, readonly) NSData *dataRepresentation; // image where available

+ (id) contactWithDictionary: (NSDictionary *) dict;
+ (id) contactWithData: (NSData *) data;
@end