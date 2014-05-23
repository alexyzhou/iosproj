//
//  VJNYPOJOHttpResult.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VJNYUtilities.h"
#import "VJNYPOJOUser.h"
#import "VJNYPOJOChannel.h"
#import "VJNYPOJOVideo.h"
#import "VJNYHTTPResultCode.h"
#import "VJNYHTTPHelper.h"

@interface VJNYPOJOHttpResult : NSObject

@property(nonatomic) VJNYHTTPResultCode result;
@property(nonatomic, strong) NSString* action;
@property(nonatomic, strong) id response;

+(VJNYPOJOHttpResult*)resultFromResponseString:(NSString*)response;

@end
