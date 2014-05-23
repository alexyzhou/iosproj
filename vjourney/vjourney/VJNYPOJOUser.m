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
@synthesize avatarUrl=_avatarUrl;
@synthesize token=_token;

+(VJNYPOJOUser*)instance {
    if (_instance == NULL) {
        _instance = [[VJNYPOJOUser alloc] init];
    }
    return _instance;
}

@end

