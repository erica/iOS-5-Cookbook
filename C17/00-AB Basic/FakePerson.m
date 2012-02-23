//
//  FakePerson.m
//  HelloWorld
//
//  Created by Erica Sadun on 8/25/11.
//  Copyright (c) 2011 Up To No Good, Inc. All rights reserved.
//

#import "FakePerson.h"

// Webservius: http://www.fakenamegenerator.com/api.php
// Please please sign up for your own key. It's not exactly a security threat here including my own, but it's better if you sign up yourself. Thanks! I am limited to 50 calls per month and they go *really* fast. You can also download a batch of a few thousand fake identities at once.
// 
// Other services:
// http://igorbass.com/rand/
// http://www.identitygenerator.com/

#define FAKEURL [NSURL URLWithString:@"http://svc.webservius.com/v1/CorbanWork/fakename?wsvKey=E0XfHczHb2OsNCuFD7UhCGfgmF7usL6I&output=json&c=us&n=us&gen=0"]

@implementation FakePerson

+ (ABContact *) contactWithIdentity: (NSDictionary *) identity
{
    if (!identity) return nil;
    
    ABContact *contact = [ABContact contact];
    
    contact.firstname = IDVALUE(@"given_name");
    contact.middlename = IDVALUE(@"middle_name");
    contact.lastname = IDVALUE(@"surname");
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    
    NSString *birthday = IDVALUE(@"birthday");
    contact.birthday = [formatter dateFromString:birthday];
    
    // Multivalue items
    NSDictionary *address = [ABContact addressWithStreet:IDVALUE(@"street1") 
                                                withCity:IDVALUE(@"city") 
                                               withState:IDVALUE(@"state") 
                                                 withZip:IDVALUE(@"zip")
                                             withCountry:IDVALUE(@"country_code") 
                                                withCode:nil];
    NSMutableArray *addresses = [NSMutableArray array];
    [addresses addObject:[ABContact dictionaryWithValue:address andLabel:kABHomeLabel]];
    contact.addressDictionaries = addresses;
    
    NSMutableArray *emails = [NSMutableArray array];
    [emails addObject:[ABContact dictionaryWithValue:IDVALUE(@"email_address") andLabel:kABWorkLabel]];
    contact.emailDictionaries = emails;
    
    NSMutableArray *phones = [NSMutableArray array];
    [phones addObject:[ABContact dictionaryWithValue:IDVALUE(@"phone_number") andLabel:kABPersonPhoneMobileLabel]];
    contact.phoneDictionaries = phones;
    
    NSMutableArray *urls = [NSMutableArray array];
    [urls addObject:[ABContact dictionaryWithValue:IDVALUE(@"domain") andLabel:kABPersonHomePageLabel]];
    contact.urlDictionaries = urls;
    return contact;
}

+ (NSDictionary *) fetchIdentity
{
    NSURLResponse *response;
    NSError *error;
    NSURLRequest *request = [NSURLRequest requestWithURL:FAKEURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!data)
    {
        NSLog(@"Error fetching fake info.");
        return nil;
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSDictionary *identity = [dictionary objectForKey:@"identity"];
    
    if (!dictionary || !identity)
    {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Error parsing fake JSON info: %@", dataString);
        return nil;
    }
    
    return identity;
}

+ (ABContact *) randomPerson
{
    NSDictionary *identity = [self fetchIdentity];
    if (!identity) return nil;
    
    ABContact *contact = [self contactWithIdentity:identity];
    return contact;
}
@end
