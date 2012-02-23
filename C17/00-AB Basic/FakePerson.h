//
//  FakePerson.h
//  HelloWorld
//
//  Created by Erica Sadun on 8/25/11.
//  Copyright (c) 2011 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABContactsHelper.h"

#define IDVALUE(_key_) [[identity objectForKey:_key_] objectForKey:@"value"]

@interface FakePerson : NSObject
+ (ABContact *) randomPerson;
+ (NSDictionary *) fetchIdentity;
@end
