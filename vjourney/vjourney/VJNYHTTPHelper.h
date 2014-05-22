//
//  VJNYHTTPHelper.h
//  vjourney
//
//  Created by alex on 14-5-16.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface VJNYHTTPHelper : NSObject
+(NSURL*)connectionUrlByAppendingRequest:(NSString*)request;
+(NSString*)mediaPlayCodeWithURL:(NSString*)url andWidth:(NSInteger)width andHeight:(NSInteger)height;
+(void)sendJSONRequest:(NSString*)target WithParameters:(NSMutableDictionary*)parameters AndDelegate:(id<ASIHTTPRequestDelegate>) delegate;
+(void)getJSONRequest:(NSString*)target WithParameters:(NSMutableDictionary*)parameters AndDelegate:(id<ASIHTTPRequestDelegate>) delegate;

@end