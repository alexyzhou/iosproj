//
//  VJNYDataCache.h
//  vjourney
//
//  Created by alex on 14-5-23.
//  Copyright (c) 2014年 HKPolyUSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VJNYDataCacheDelegate;

@interface VJNYDataCache : NSObject

+(VJNYDataCache*)instance;
-(UIImage*)dataByURL:(NSString*)url;
-(void)requestDataByURL:(NSString*)url WithDelegate:(id<VJNYDataCacheDelegate>)delegate AndIdentifier:(id)identifier AndMode:(int)mode;
+ (void)loadImage:(UIImageView*)cell WithUrl:(NSString*)url AndMode:(int)mode AndIdentifier:(id)identifier AndDelegate:(id<VJNYDataCacheDelegate>)delegate;
@end

@protocol VJNYDataCacheDelegate <NSObject>
@required
- (void) dataRequestFinished:(UIImage*)data WithIdentifier:(id)identifier AndMode:(int)mode;
@end