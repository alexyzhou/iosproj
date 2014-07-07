//
//  VJNYPojoUser.m
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYPOJOUser.h"

@implementation VJNYPOJOUser

static VJNYPOJOUser* _instance;

@synthesize uid=_uid;
@synthesize name=_name;
@synthesize username=_username;
@synthesize avatarUrl=_avatarUrl;
@synthesize token=_token;
@synthesize gender=_gender;
@synthesize age=_age;
@synthesize coverUrl=_coverUrl;
@synthesize description=_description;

+(VJNYPOJOUser*)sharedInstance {
    if (_instance == NULL) {
        _instance = [[VJNYPOJOUser alloc] init];
    }
    return _instance;
}

-(void)insertIdentityToDirectory:(NSMutableDictionary*)dic {
    [dic setObject:[_uid stringValue] forKey:@"identity"];
    [dic setObject:_token forKey:@"token"];
}

@end

