//
//  VJNYUploaderHelper.m
//  vjourney
//
//  Created by alex on 14-7-4.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import "VJNYUploaderHelper.h"

@implementation VJNYUploaderHelper

static VJNYUploaderHelper* _instance = nil;

+(VJNYUploaderHelper*)sharedInstance {
    if (_instance == nil) {
        _instance = [[VJNYUploaderHelper alloc] init];
    }
    return _instance;
}

-(id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

@end
